from datetime import date
import doctest

import pylons.test
from pylons import config

from ututi.model import LocationTag, Group, File, meta
from ututi.model.users import User

from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser
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
    suite.layer = UtutiLayer
    return suite

def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
    setUpUser()
    u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
    meta.set_active_user(u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')
    meta.Session.add(g)
    meta.Session.commit()

    meta.set_active_user(u.id)
