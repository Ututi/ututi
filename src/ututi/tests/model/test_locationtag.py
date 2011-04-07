import doctest

from ututi.model import LocationTag, meta
from ututi.tests import UtutiLayer
import ututi

def test_LocationTag_flatten():
    """Test if location tags are flattened correctly.

        >>> tag = LocationTag.get(u'uni')
        >>> [t.title for t in tag.flatten]
        [u'U-niversity', u'D-epartment']

    """

def test_LocationTag_getbytitle():
    r"""Tests for location tag retrieval by the full title.

    LocationTag has a classmethod get_by_title, which can retrieve
    tags by their full title.

        >>> tag = LocationTag.get_by_title(u'U-niversity')
        >>> tag.title
        u'U-niversity'

    Tags can also be retrieved by traversing the hierarchy.

        >>> tag = LocationTag.get_by_title([u'U-niversity', u'D-epartment'])
        >>> tag.title_short, tag.title
        (u'dep', u'D-epartment')

    """


def test_LocationTag_get():
    r"""Tests for location tag retrieval by the short title.

    The defualt LocationTag getter retrieves location tags by their
    short title. (a parent == None is assumed)

        >>> tag = LocationTag.get(u'uni')
        >>> tag.title
        u'U-niversity'

    Or if passed a list of tags, the first tag is considered to be a
    parent, of the second one and so on...

        >>> tag = LocationTag.get([u'uni', u'dep'])
        >>> tag.title_short, tag.title
        (u'dep', u'D-epartment')

    The lookup is case insensitive.

        >>> tag = LocationTag.get([u'Uni', u'DeP'])
        >>> tag.title_short, tag.title
        (u'dep', u'D-epartment')

    Even though tags themselves can have varying cases in their short
    titles:

        >>> meta.Session.add(LocationTag(u'Libre University', u'Luni', u'', member_policy='PUBLIC'))
        >>> meta.Session.commit()

        >>> tag = LocationTag.get(u'luni')
        >>> tag.title_short, tag.title
        (u'luni', u'Libre University')

    """

def test_unique_locationtag():
    """
    It should be impossible to have conflicting location tags.
    >>> meta.Session.add(LocationTag(u'Kauno Technologijos Universitetas', u'KTU', u'', member_policy='PUBLIC'))
    >>> meta.Session.commit()
    >>> meta.Session.add(LocationTag(u'Kauno Technologijos Universitetas', u'KTU', u'', member_policy='PUBLIC'))
    >>> meta.Session.commit()
    Traceback (most recent call last):
    ...
    IntegrityError: (IntegrityError) duplicate key value violates unique constraint "parent_title_unique_idx"
    ...
    >>> meta.Session.rollback()
    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite

def test_setup(test):
    ututi.tests.setUp(test)
    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    meta.Session.add(uni)
    dep = LocationTag(u'D-epartment', u'dep', u'', uni, member_policy='PUBLIC')
    meta.Session.add(dep)

    meta.Session.commit()
