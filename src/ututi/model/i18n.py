from sqlalchemy import orm, Column
from sqlalchemy.types import Unicode
from sqlalchemy.schema import Table
from sqlalchemy.orm import relation, backref
from sqlalchemy.orm.exc import NoResultFound

from ututi.model import meta

languages_table = None
language_texts_table = None

class Language(object):

    def __init__(self, id, title):
        self.id = id
        self.title = title

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls)\
                    .filter_by(id=id)\
                    .one()
        except NoResultFound:
            return None

class LanguageText(object):

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


def setup_orm(engine):
    global languages_table
    languages_table = Table(
        "languages",
        meta.metadata,
        Column('title', Unicode(assert_unicode=True)),
        autoload=True,
        autoload_with=engine)

    global language_texts_table
    language_texts_table = Table(
        "language_texts",
        meta.metadata,
        Column('text', Unicode(assert_unicode=True)),
        autoload=True,
        autoload_with=engine)

    orm.mapper(Language, languages_table)
    orm.mapper(LanguageText,
               language_texts_table,
               properties={
                   'language': relation(Language,
                                        backref=backref('texts',
                                            order_by=language_texts_table.c.id.asc()))})
