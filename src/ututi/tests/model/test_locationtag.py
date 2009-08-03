from zope.testing import doctest

from ututi.model import LocationTag, meta
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


def test_LocationTag_get():
    r"""Tests for location tag retrieval by the short title.

    The defualt LocationTag getter retrieves location tags by their
    short title. (a parent == None is assumed)

        >>> tag = LocationTag.get(u'vu')
        >>> tag.title
        u'Vilniaus universitetas'

    Or if passed a list of tags, the first tag is considered to be a
    parent, of the second one and so on...

        >>> tag = LocationTag.get([u'vu', u'ef'])
        >>> tag.title_short, tag.title
        (u'ef', u'Ekonomikos fakultetas')

    The lookup is case insensitive.

        >>> tag = LocationTag.get([u'Vu', u'eF'])
        >>> tag.title_short, tag.title
        (u'ef', u'Ekonomikos fakultetas')

    Even though tags themselves can have varying cases in their short
    titles:

        >>> meta.Session.add(LocationTag(u'Kauno Technologijos Universitetas', u'KTU', u''))
        >>> meta.Session.commit()

        >>> tag = LocationTag.get(u'ktu')
        >>> tag.title_short, tag.title
        (u'KTU', u'Kauno Technologijos Universitetas')

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
