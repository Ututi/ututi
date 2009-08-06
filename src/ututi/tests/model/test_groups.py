from datetime import date
from zope.testing import doctest

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, File, User, meta

from ututi.tests import PylonsLayer
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
        [<ututi.model.User object at ...>]

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
        ...         meta.Session.delete(file)
        >>> meta.Session.commit()
        >>> meta.Session.expire_all()

        >>> group = Group.get("moderators")
        >>> printTree(group)

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = PylonsLayer
    return suite

def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')
    u = User.get('admin@ututi.lt')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)
    meta.Session.commit()
