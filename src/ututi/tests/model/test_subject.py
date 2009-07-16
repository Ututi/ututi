from zope.testing import doctest

from ututi.model import LocationTag
from ututi.model import Subject, meta
from ututi.tests import PylonsLayer


def test_Subject_get():
    r"""Tests for subject retrieval from the database.

    Subject get classmethod returns subjects by their id, the id at
    the moment is a string that is shown in the subject url.

        >>> subject = Subject.get(LocationTag.get('vu'), 'mat_analize')
        >>> subject.id, subject.title
        ('mat_analize', u'Matematin\u0117 analiz\u0117')

    In the future though, a subject will be uniquely identified by a
    location tag as well which will look like this:

        >> Subject.get('vu', 'mif', 'mat_analize')

    or this:

        >> Subject.get(LocationTag.get('vu', 'mif'), 'mat_analize')

    Which will open a whole can of AmbiguityError kind of errors,
    because we will have to limit tag names and subject names so they
    would never clash with tag names. So creating a subject:

         >> Subject(LocationTag('vu'), 'mif', 'Mif')

    Will raise an error. Same for tags that match subject names.

         >> LocationTag('vu', 'mif', 'mat_analize')

    Should not work.

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
