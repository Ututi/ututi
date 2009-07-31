from zope.testing import doctest
from ututi.tests import PylonsLayer

from ututi.model import meta, SearchItem, Subject, Page, Group, LocationTag
from ututi.lib.search import search

def test_basic_search():
    """Tests basic searching by text contents.

    A basic test: we set up a group and search for its text.
    Set the indexing language first, something the controllers always do for us.
        >>> t = meta.Session.execute("SET default_text_search_config = 'public.lt';;");
        >>> g = Group('new_group', u'Bioinformatikai', description=u'Grup\xc4\x97 kurioje domimasi biologija ir informatika')
        >>> meta.Session.add(g)
        >>> meta.Session.commit()
        >>> results = search(u'biologija')
        >>> [result.group.title for result in results]
        [u'Bioinformatikai']

    Let's try out the lithuanian spelling:
        >>> [result.group.title for result in search(u'informatikos')]
        [u'Bioinformatikai']

    Let's add a subject and see what we get:
        >>> s = Subject('biologija', u'Biologijos pagrindai', LocationTag.get(u'vu'))
        >>> meta.Session.add(s)
        >>> [result.object.title for result in search(u'biologija')]
        [u'Bioinformatikai', u'Biologijos pagrindai']

    Let's filter by type:
        >>> [result.object.title for result in search(u'biologija', type='group')]
        [u'Bioinformatikai']

    No pages have been added yet:
        >>> [result.object.title for result in search(u'biologija', type='page')]
        []
    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
