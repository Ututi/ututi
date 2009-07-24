from zope.testing import doctest

from ututi.model import LocationTag
from ututi.tests import PylonsLayer


def test_LocationTag_getbytitle():
    r"""Tests for location tag retrieval by the full title.

    LocationTag has a classmethod get_by_title, which can retrieve
    tags by their full title.

        >>> tag = LocationTag.get_by_title(u'Vilniaus universitetas')
        >>> tag.title
        u'Vilniaus universitetas'

    Tags can also be retrieved by traversing the hierarchy.

        >>> tag = LocationTag.get_by_title([u'Vilniaus universitetas', u'Ekonomikos fakultetas'])
        >>> tag.title_short, tag.title
        (u'ef', u'Ekonomikos fakultetas')


    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
