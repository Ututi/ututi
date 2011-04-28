from datetime import date
import doctest

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, File, Subject, meta
from ututi.model.users import User

from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser
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

        >>> printTree(group)
        Another text file
        some folder:
           A Text file

    """

def test_subject_files():
    """Test subject file management.

        >>> subject = Subject.get(LocationTag.get(u'uni'), "subject")

        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> subject.files.append(f)

        >>> f = File(u"other.txt", u'Another text file', mimetype='text/plain', data="Wassup2")
        >>> subject.files.append(f)

        >>> meta.Session.commit()

        >>> subject = Subject.get(LocationTag.get(u'uni'), "subject")

        >>> subject.files
        [<ututi.model.File object at ...>, <ututi.model.File object at ...>]

    Check if location is synchronized for files:

        >>> res = meta.set_active_user(1)
        >>> [f.location_id for f in subject.files]
        [1L, 1L]

        >>> subject.location_id = LocationTag.get(u'uni/dep').id
        >>> meta.Session.commit()

        >>> [f.location_id for f in subject.files]
        [2L, 2L]

        >>> printTree(subject)
        Another text file
        some folder:
           A Text file

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
    uni = LocationTag.get(u'uni')
    dep = LocationTag(u'department', u'dep', u'', uni, member_policy='PUBLIC')
    meta.Session.add(dep)
    meta.Session.commit()

    u = User.get('admin@uni.ututi.com', uni)
    meta.set_active_user(u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)

    meta.Session.add(Subject(u'subject', u'A Generic subject', uni, u''))
    meta.Session.commit()

    meta.set_active_user(u.id)
