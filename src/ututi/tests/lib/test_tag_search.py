from zope.testing import doctest

from ututi.model import LocationTag, User, meta

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

    u = User.get(u'admin@ututi.lt')
    from ututi.model import initialize_dictionaries
    initialize_dictionaries(meta.engine)
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)
    meta.Session.execute("SET default_text_search_config TO 'public.lt'")

    l = LocationTag(u'Kauno technologijos universitetas', u'ktu', u'')
    f = LocationTag(u'Ekologijos fakultetas', u'ef', u'', l)
    meta.Session.add(l)
    meta.Session.add(f)

    meta.Session.commit()
    meta.Session.execute("SET default_text_search_config TO 'public.lt'")


def tear_down(test):
    ututi.tests.tearDown(test)
