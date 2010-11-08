from zope.testing import doctest

from ututi.model import User
from ututi.model import LocationTag, Subject, meta
from ututi.model.events import Event
from ututi.tests import UtutiLayer
import ututi


def test_Subject_get():
    r"""Tests for subject retrieval from the database.

    Subject get classmethod returns subjects by their id, the id at
    the moment is a string that is shown in the subject url.

        >>> subject = Subject.get(LocationTag.get([u'vu']), 'mat_analize')
        >>> subject.subject_id, subject.title
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


def test_subject_create():
    r"""Test subject creation and events

        >>> s = Subject('some_id', u'Subject title', LocationTag.get([u'vu']))
        >>> meta.Session.add(s)
        >>> meta.Session.commit()
        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> evt = meta.Session.query(Event).filter(Event.context == s).all()
        >>> [e.render() for e in evt]
        [u'New subject ... was created']

        >>> s = Subject.get(LocationTag.get([u'vu']), 'some_id')
        >>> mod_time = s.modified_on

    If we modify the subject, we should get a subject modification event.

        >>> s.description = u'New description'
        >>> meta.Session.commit()
        >>> evt = meta.Session.query(Event).filter(Event.context == s).all()
        >>> [e.render() for e in evt]
        [u'New subject ... was created', u'Subject ... was modified']

     And the subject's modification time should change:
        >>> s = Subject.get(LocationTag.get([u'vu']), 'some_id')

     The modification time of the content item should be updated
        >>> s.modified_on > mod_time
        True

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

    u = User.get('admin@ututi.lt')
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)

    meta.Session.add(Subject(u'mat_analize', u'Matematin\u0117 analiz\u0117', LocationTag.get(u'vu'), u'prof. E. Misevi\u010dius'))

    meta.Session.commit()

    u = User.get('admin@ututi.lt')
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)

