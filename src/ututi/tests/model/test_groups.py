from datetime import date
import doctest

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, File, meta
from ututi.model import ContentItem
from ututi.model.mailing import GroupMailingListMessage
from ututi.lib.mailinglist import post_message
from ututi.model.users import User
from ututi.model.events import Event
from ututi.lib.mailer import mail_queue

from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser, setUpModeratorGroup
import ututi


def printTree(group):
    for folder in group.folders:
        if folder.title == '':
            for file in folder:
                print file.title
        else:
            print folder.title + ":"
            for file in folder:
                print '   ' + file.title


def test_group_create():
    """Test group creation event.

    Add event, when creating group:

        >>> g = Group('testgroup', u'Testing group', LocationTag.get(u'vu'), date(date.today().year, 1, 1), u'Testing group')
        >>> meta.Session.add(g)
        >>> meta.Session.commit()
        >>> res = meta.set_active_user(1)
        >>> evt = meta.Session.query(Event).filter(Event.context == g).all()
        >>> [e.render() for e in evt]
        [u'New group ... was created']
    """


def test_group_files():
    """Tests for group file management.

    Groups can have files attached to them, so that our users could
    share them among themselves. Files are stored in an attribute of a
    group object. So let's get group and add some files for it:

        >>> group = Group.get("moderators")

        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> group.files.append(f)

        >>> f = File(u"other.txt", u'Another text file', mimetype='text/plain', data="Wassup2")
        >>> group.files.append(f)

        >>> meta.Session.commit()

        >>> group = Group.get("moderators")
        >>> group.files
        [<ututi.model.File object at ...>, <ututi.model.File object at ...>]

        >>> group.last_seen_members
        [<ututi.model.users.User object at ...>]

        >>> printTree(group)
        Another text file
        some folder:
           A Text file

    """


def test_empty_folders():
    """Test for empty folder creation.

    If you want to create an empty folder you have to use a null file
    for that.

        >>> group = Group.get("moderators")
        >>> group.files.append(File.makeNullFile(u"some folder"))
        >>> meta.Session.commit()
        >>> meta.Session.expire_all()

    Null files are visible in the files list of the group:

        >>> group = Group.get("moderators")
        >>> group.files
        [<ututi.model.File object at ...>]

    But the file will not show up in folders:

        >>> printTree(group)
        some folder:

    You can delete a folder, even though it's not a very convenient
    operation:

        >>> for file in list(group.files):
        ...     if file.folder == 'some folder':
        ...         group.files.remove(file)
        ...         meta.set_active_user(1)
        ...         meta.Session.delete(file)
        >>> meta.Session.commit()
        >>> meta.Session.expire_all()

        >>> group = Group.get("moderators")
        >>> printTree(group)

    """

def test_invitations():
    """Test group invitations and membership requests.

    Let's say a user wants to join a group.
        >>> g = Group.get("moderators")
        >>> u = User.get("admin@uni.ututi.com", LocationTag.get(u'uni'))
        >>> g.request_join(u)
        <ututi.model.PendingRequest object ...>

    The new reqest to join should appear in group's request collection:
        >>> g.requests
        [<ututi.model.PendingRequest object at ...>]

        >>> len(g.requests)
        1

    But invitations should remain empty:
        >>> g.invitations
        []

    """

def test_memberships():
    """Test group memberships.

    >>> g = Group.get("moderators")
    >>> u = User.get("admin@uni.ututi.com", LocationTag.get(u'uni'))
    >>> g.add_member(u, True)
    >>> meta.Session.commit()
    >>> len(g.members)
    1
    """

def test_message_deletion_cascade():
    """Test group message deletion after group is deleted

    >>> g = Group.get("moderators")
    >>> u = User.get("admin@uni.ututi.com", LocationTag.get(u'uni'))
    >>> g.add_member(u, True)
    >>> meta.Session.commit()
    >>> meta.set_active_user(u.id)
    >>> msg_id = post_message(g, u, 'test', 'test message body').id
    >>> ci = meta.Session.query(ContentItem).filter_by(id=msg_id).all()
    >>> len(ci)
    1
    >>> meta.Session.delete(g)

    Make sure mailing list message content items are deleted.

    >>> ci = meta.Session.query(ContentItem).filter_by(id=msg_id).all()
    >>> len(ci)
    0
    >>> mail_queue[:] = []


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
