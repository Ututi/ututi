import doctest
from datetime import date

from ututi.model import User, Group
from ututi.model import WallPost, LocationTag, meta
from ututi.model.events import Event, GroupWallPostEvent
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser, setUpModeratorGroup

import ututi


def test_wall_post_create():
    r"""Test creation of wall posts and associated triggers.

    Wall post can be of 3 kinds: group, subject and location (university, department, subdepartment).
    First create a group wall post.

    >>> post = WallPost(group_id=Group.get('moderators').id, content="This is a test")
    >>> meta.Session.add(post)
    >>> meta.Session.commit()
    >>> posts = meta.Session.query(WallPost).filter(WallPost.content=="This is a test").all()
    >>> len(posts)
    1
    >>> posts[0].content
    'This is a test'


    Now lets see if event was created.

    >>> event = meta.Session.query(GroupWallPostEvent).filter(GroupWallPostEvent.object_id==post.id).one()
    >>> event.context.content
    'This is a test'

    TODO: test other trigger paths

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
    setUpModeratorGroup()

    u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
    meta.set_active_user(u.id)
