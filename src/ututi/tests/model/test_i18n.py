import doctest

from ututi.tests import UtutiLayer

import ututi

def test_i18n_text_handling():
    """Tests I18nText class and version handling.

        >>> from ututi.model.i18n import Language, I18nText, I18nTextVersion
        >>> from ututi.model import meta

        >>> text = I18nText()
        >>> text.versions
        []

        >>> text.set_text('lt', u'Lietuvi\u0161ka versija.')
        >>> text.set_text('en', u'English version.')
        >>> text.set_text('pl', u'Wersja polska.')
        >>> len(text.versions)
        3
        >>> meta.Session.add(text)
        >>> meta.Session.commit()

        Text for a specific language can be retrieved in two ways.
        Retrieving the version object:

        >>> text.get_version('lt').text
        u'Lietuvi\u0161ka versija.'

        We can pass Language object as well as it's identifier

        >>> en = Language.get('en')
        >>> text.get_version(en).text
        u'English version.'

        Or we can use get_text, which does some language selection and
        fallback magic, illustrated below. For that purpose we will
        set up template context object stub:

        >>> from pylons import tmpl_context as c
        >>> class ContextStub: pass
        ...
        >>> c._push_object(ContextStub())

        >>> c.lang = 'lt'
        >>> text.get_text()
        u'Lietuvi\u0161ka versija.'

        >>> c.lang = 'pl'
        >>> text.get_text()
        u'Wersja polska.'

        We can specify the language explicitly if we want to:

        >>> text.get_text(language='lt')
        u'Lietuvi\u0161ka versija.'

        If the text in given language is not available, it tries
        to fall back to english:

        >>> text.get_text(language='kr')
        u'English version.'

        But we can change the fallback language:

        >>> text.get_text(language='kr', fallback='lt')
        u'Lietuvi\u0161ka versija.'

        Text versions can be deleted:

        >>> text.get_version('pl').delete()
        >>> meta.Session.commit()
        >>> text.get_version('pl') is None
        True
        >>> len(text.versions)
        2

        Note that set_text does not create any new version
        objects:

        >>> len(I18nTextVersion.all())
        2
        >>> text.set_text('lt', u'Nauja lietuvi\u0161ka versija.')
        >>> text.set_text('en', u'New english version.')
        >>> meta.Session.commit()
        >>> len(I18nTextVersion.all())
        2

        >>> text.get_version('lt').text
        u'Nauja lietuvi\u0161ka versija.'

        >>> text.get_version('en').text
        u'New english version.'

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
