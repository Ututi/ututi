from sqlalchemy import orm, Column
from sqlalchemy.schema import Table
from sqlalchemy.orm import relation, backref
from sqlalchemy.orm.exc import NoResultFound

from pylons import tmpl_context as c

from ututi.model import meta
from ututi.model.base import Model

class Language(Model):

    def __init__(self, id, title):
        self.id = id
        self.title = title


class I18nText(Model):

    def get_text(self, language=None, fallback='en'):
        """Get a text for a given language. If no language
        is specified, attempts to get it from context. Falls
        back to the given language or any other version.
        Returns empty string if no text is found."""

        if not self.versions:
            return '' # early departure

        if language is None:
            try:
                language = c.lang
            except AttributeError:
                pass

        version = self.get_version(language)
        if version is not None:
            return version.text

        version = self.get_version(fallback)
        if version is not None:
            return version.text

        return self.versions[0].text

    def set_text(self, language, text):
        """Save text version for a given language. This should be
        the primary way of saving i18n texts."""

        version = self.get_version(language)

        if version is None:
            self.versions.append(I18nTextVersion(language, text))
        else:
            version.text = text

    def get_version(self, language):
        """Get text version for the given language. Returns
        None if version for this language does not exist."""

        if isinstance(language, basestring):
            language = Language.get(language)

        for version in self.versions:
            if version.language == language:
                return version

        return None


class I18nTextVersion(Model):

    def __init__(self, language, text=None):
        if isinstance(language, basestring):
            language = Language.get(language)

        self.language = language
        self.text = text


class LanguageText(object):
    # LanguageText is deprecated until it uses I18nText

    def __init__(self, id, lang, text):
        self.id = id
        self.text = text
        if isinstance(lang, Language):
            self.language = lang
        else:
            self.language_id = lang

    @classmethod
    def get(cls, id, lang):
        try:
            if isinstance(lang, Language):
                return meta.Session.query(cls)\
                        .filter_by(id=id, language=lang)\
                        .one()
            else:
                return meta.Session.query(cls)\
                        .filter_by(id=id, language_id=lang)\
                        .one()
        except NoResultFound:
            return None


class Country(Model):

    @classmethod
    def get_by_name(cls, name):
        try:
            return meta.Session.query(cls).filter_by(name=name).one()
        except NoResultFound:
            return None

    @classmethod
    def get_by_locale(cls, locale):
        try:
            return meta.Session.query(cls).filter_by(locale=locale).one()
        except NoResultFound:
            return None

    @classmethod
    def all(cls):
        return meta.Session.query(cls).order_by(cls.name.asc()).all()


def setup_tables(engine):
    Table("languages", meta.metadata,
          autoload=True,
          extend_existing=True,
          autoload_with=engine)

    Table("language_texts", meta.metadata,
          autoload=True,
          autoload_with=engine)

    Table("i18n_texts", meta.metadata,
          autoload=True,
          autoload_with=engine)

    Table("i18n_texts_versions", meta.metadata,
          autoload=True,
          autoload_with=engine)

    Table("countries", meta.metadata,
          autoload=True,
          extend_existing=True,
          autoload_with=engine)


def setup_orm():
    tables = meta.metadata.tables
    orm.mapper(Language, tables['languages'])
    orm.mapper(I18nText, tables['i18n_texts'],
               properties={
                   'versions': relation(I18nTextVersion,
                                        order_by=tables['i18n_texts_versions'].c.language_id.asc())
               })

    orm.mapper(I18nTextVersion, tables['i18n_texts_versions'],
               properties={ 'language': relation(Language) })


    # LanguageText is deprecated until it uses I18nText
    orm.mapper(LanguageText,
               tables['language_texts'],
               properties={
                   'language': relation(Language,
                                        backref=backref('texts',
                                            order_by=tables['language_texts'].c.id.asc()))})

    orm.mapper(Country,
               tables['countries'],
               properties={
                   'language': relation(Language,
                                        backref=backref('countries',
                                            order_by=tables['countries'].c.id.asc()))})

