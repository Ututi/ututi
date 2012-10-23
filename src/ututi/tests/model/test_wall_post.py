import doctest
from datetime import date

from ututi.model import User, Subject
from ututi.model import WallPost, LocationTag, meta
from ututi.model.events import Event
from ututi.model.events import SubjectWallPostEvent
from ututi.model.events import LocationWallPostEvent
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

import ututi


def test_subject_wall_post():
    r"""

    Wall post can be of 2 kinds: subject and location (university, department, subdepartment).

    Create a subject wall post now and check associated event creation

    >>> post = WallPost(subject=Subject.get(LocationTag.get(u'uni'), 'subject'), content=u'Subject wall post.')
    >>> meta.Session.add(post)
    >>> meta.Session.commit()
    >>> saved_post = meta.Session.query(WallPost).filter(WallPost.content==u'Subject wall post.').one()
    >>> saved_post.content
    u'Subject wall post.'

    See if the event was created.

    >>> event = meta.Session.query(SubjectWallPostEvent).filter(SubjectWallPostEvent.object_id==post.id).one()
    >>> event.context.content
    u'Subject wall post.'

    """


def test_location_wall_post():
    r"""
    Test wall post attachable to location.

    Create a location wall post and ensure associated event is created.

    >>> post = WallPost(location=LocationTag.get(u'uni'), content=u'This is really just locaton wall post.')
    >>> meta.Session.add(post)
    >>> meta.Session.commit()
    >>> saved_post = meta.Session.query(WallPost).filter_by(content=u'This is really just locaton wall post.').one()
    >>> saved_post.content
    u'This is really just locaton wall post.'

    Check event

    >>> event = meta.Session.query(LocationWallPostEvent).filter_by(object_id=saved_post.id).one()
    >>> event.context.content
    u'This is really just locaton wall post.'

    See location info

    >>> event.context.target_location.title_short
    u'uni'

    """


def test_wall_post_event_glue_methods():
    r"""
    Create several wall post events and ensure they have a proper glue methods that
    tie them to wall machinery properly.

    >>> subject_post = WallPost(subject=Subject.get(LocationTag.get(u'uni'), 'subject'), content=u'Subject wall post.')
    >>> meta.Session.add_all([subject_post])
    >>> meta.Session.commit()
    >>> subject_post_event = meta.Session.query(SubjectWallPostEvent).filter(SubjectWallPostEvent.object_id==subject_post.id).one()

    Subject wall post event

    >>> subject_post_event.wp_content
    u'Subject wall post.'
    >>> subject_post_event.wp_subject_id == subject_post.subject.id
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
    setUpUser()

    u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
    meta.set_active_user(u.id)
    meta.Session.add(Subject(u'subject', u'Subject',
                             LocationTag.get(u'uni'),
                             u''))
    meta.Session.commit()
    meta.set_active_user(u.id)
