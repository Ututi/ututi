import doctest
import pylons.test

from ututi.model import initialize_dictionaries
from ututi.model import LocationTag, meta

from ututi.tests import UtutiLayer
import ututi

from ututi.lib.search import tag_search


def test_tag_search():
    r"""Tests searching for location tags.

        >>> [result.tag.title for result in tag_search('ekologijos fakultetas')]
        [u'Ekologijos fakultetas']

        >>> [result.tag.title for result in tag_search('ktu ekologijos')]
        [u'Ekologijos fakultetas']

        >>> [result.tag.title for result in tag_search('ktu')]
        [u'Kauno technologijos universitetas', u'Ekologijos fakultetas']

    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup,
        tearDown=tear_down)
    suite.layer = UtutiLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
    initialize_dictionaries(meta.engine)
    config = pylons.test.pylonsapp.config
    config['default_search_dict'] = 'public.universal'

    l = LocationTag(u'Kauno technologijos universitetas', u'ktu', u'', member_policy='PUBLIC')
    f = LocationTag(u'Ekologijos fakultetas', u'ef', u'', l, member_policy='PUBLIC')
    meta.Session.add(l)
    meta.Session.add(f)

    meta.Session.execute("SET default_text_search_config TO 'public.lt'")


def tear_down(test):
    ututi.tests.tearDown(test)
