import doctest

from ututi.model import PageVersion
from ututi.model import Page
from ututi.model import meta, Subject, LocationTag
from ututi.model.users import User
from ututi.model.events import PageModifiedEvent
from ututi.model.events import SubjectModifiedEvent
from ututi.tests import UtutiLayer

def test_grouping_subject_events():
    r"""Test grouping of subject events
        Let's create and update a subject. The creation and update events should be grouped.

        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> s = Subject('some_id', u'Subject title', LocationTag.get([u'vu']))
        >>> meta.Session.add(s)
        >>> meta.Session.commit()

        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> s.title = u'A new subject title'
        >>> meta.Session.commit()

    The modification event is now the parent of the creation event (the newest event is the parent)

        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(2L, 'subject_modified', [1L])]

    Let's update the subject again and see if the newest event is really the parent:

        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> s.title = u'A newer subject title'
        >>> meta.Session.commit()

        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(3L, 'subject_modified', [1L, 2L]), (2L, 'subject_modified', [])]

    Only modifications by the same user are grouped.
        >>> petras = User(u'Petras', 'qwerty', gen_password=True)
        >>> meta.Session.add(petras)
        >>> meta.Session.commit()

        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % petras.id)
        >>> s.title = u'The old subject title'
        >>> meta.Session.commit()
        >>> events = meta.Session.query(SubjectModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(3L, 'subject_modified', [1L, 2L]), (2L, 'subject_modified', []), (4L, 'subject_modified', [])]
    """

def test_grouping_page_events():
    r"""Test grouping of page events

        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> s = Subject('some_id', u'Subject title', LocationTag.get([u'vu']))
        >>> meta.Session.add(s)
        >>> page = Page(u'Some coursework', u'Some information about it.')
        >>> s.pages.append(page)
        >>> meta.Session.commit()

    Let's update the page:
        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> version = PageVersion(u'Some coursework (updated)',
        ...                       u'Some more information about it.')
        >>> page.versions.append(version)
        >>> meta.Session.commit()

        >>> events = meta.Session.query(PageModifiedEvent).all()
        >>> [(e.id, e.event_type, [c.id for c in e.children]) for e in events]
        [(3L, 'page_modified', [2L])]

    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite
