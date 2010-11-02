from datetime import date
from zope.testing import doctest

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, File, User, Subject, meta

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

        >>> printTree(group)
        Another text file
        some folder:
           A Text file

    """

def test_subject_files():
    """Test subject file management.

        >>> subject = Subject.get(LocationTag.get(u'vu'), "mat_analize")

        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> subject.files.append(f)

        >>> f = File(u"other.txt", u'Another text file', mimetype='text/plain', data="Wassup2")
        >>> subject.files.append(f)

        >>> meta.Session.commit()

        >>> subject = Subject.get(LocationTag.get(u'vu'), "mat_analize")

        >>> subject.files
        [<ututi.model.File object at ...>, <ututi.model.File object at ...>]

Check if location is synchronized for files:
        >>> res = meta.Session.execute("SET ututi.active_user TO 1")
        >>> [f.location_id for f in subject.files]
        [1L, 1L]

        >>> subject.location_id = LocationTag.get(u'vu/ef').id
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
    suite.layer = PylonsLayer
    return suite

def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)

    u = User.get('admin@ututi.lt')
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)
    meta.Session.add(Subject(u'mat_analize', u'Matematin\u0117 analiz\u0117', LocationTag.get(u'vu'), u'prof. E. Misevi\u010dius'))
    meta.Session.commit()
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)
