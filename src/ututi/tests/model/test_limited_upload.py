from datetime import date
from zope.testing import doctest

import pylons.test
from pylons import config

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, File, User, meta

from ututi.tests import PylonsLayer
import ututi

def test_group_uploadstatus():
    """Tests for group file upload limiting.

        >>> config._push_object(pylons.test.pylonsapp.config)

        >>> group = Group.get("moderators")

        >>> f = File(u"some.txt", u'A Text file', mimetype='text/plain', data="Wassup?")
        >>> f.folder = u"some folder"
        >>> group.files.append(f)

        >>> f = File(u"other.txt", u'Another text file', mimetype='text/plain', data="12345678901234567890")
        >>> group.files.append(f)
        >>> meta.Session.commit()

        >>> group.paid
        False

        >>> group.upload_status == group.CAN_UPLOAD
        False

        >>> config._pop_object(pylons.test.pylonsapp.config)

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

    meta.Session.add(g)
    meta.Session.commit()
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)
