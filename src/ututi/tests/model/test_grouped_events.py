import doctest

from datetime import date

from ututi.model import LocationTag
from ututi.model import File
from ututi.model import GroupMember
from ututi.model import GroupMembershipType
from ututi.model import Group
from ututi.model import PageVersion
from ututi.model import Page
from ututi.model import meta, Subject, LocationTag
from ututi.model.users import User
from ututi.model.events import FileUploadedEvent
from ututi.model.events import PageModifiedEvent
from ututi.model.events import SubjectModifiedEvent

from ututi.tests import setUp
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

def test_grouping_subject_events():
    r"""Test grouping of subject events
        Let's create and update a subject. The creation and update events should be grouped.

        >>> res = meta.set_active_user(1)
        >>> s = Subject('some_id', u'Subject title', LocationTag.get([u'vu']))
        >>> meta.Session.add(s)
        >>> meta.Session.commit()

        >>> res = meta.set_active_user(1)
        >>> s.title = u'A new subject title'
        >>> meta.Session.commit()

    The modification event is now the parent of the creation event (the newest event is the parent)

        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(4L, u'subject_modified', [3L])]

    Let's update the subject again and see if the newest event is really the parent:

        >>> res = meta.set_active_user(1)
        >>> s.title = u'A newer subject title'
        >>> meta.Session.commit()

        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(5L, u'subject_modified', [3L, 4L]), (4L, u'subject_modified', [])]

    Only modifications by the same user are grouped.
        >>> petras = User(u'Petras', 'petras', LocationTag.get(u'uni'), 'qwerty', gen_password=True)
        >>> meta.Session.add(petras)
        >>> meta.Session.commit()

        >>> res = meta.set_active_user(petras.id)
        >>> s.title = u'The old subject title'
        >>> meta.Session.commit()
        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(5L, u'subject_modified', [3L, 4L]), (4L, u'subject_modified', []), (6L, u'subject_modified', [])]
    """

def test_grouping_page_events():
    r"""Test grouping of page events

        >>> res = meta.set_active_user(1)
        >>> s = Subject('some_id', u'Subject title', LocationTag.get([u'vu']))
        >>> meta.Session.add(s)
        >>> page = Page(u'Some coursework', u'Some information about it.')
        >>> s.pages.append(page)
        >>> meta.Session.commit()

    Let's update the page:
        >>> res = meta.set_active_user(1)
        >>> version = PageVersion(u'Some coursework (updated)',
        ...                       u'Some more information about it.')
        >>> page.versions.append(version)
        >>> meta.Session.commit()

        >>> events = meta.Session.query(PageModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(5L, u'page_modified', [4L])]

    """

def test_grouping_file_events():
    r"""Test if file events are being grouped correctly

    Let's upload a couple of files to a group:
        >>> group = Group.get("moderators")
        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> group.files.append(f)
        >>> meta.Session.commit()

        >>> res = meta.set_active_user(1)
        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> group.files.append(f)
        >>> meta.Session.commit()

        >>> events = meta.Session.query(FileUploadedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(4L, u'file_uploaded', [3L]), (3L, u'file_uploaded', [])]

     """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite

def test_setup(test):
    """Create some models for the test."""
    setUpUser()
    u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
    meta.set_active_user(u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)
    meta.Session.commit()
    meta.set_active_user(u.id)

