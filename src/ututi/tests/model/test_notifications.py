import doctest
import datetime

from ututi.model import LocationTag
from ututi.model import Notification, meta
from ututi.model.users import User
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

import ututi

def test_notifications():
    """A simple test to see if the notifications work.

        >>> admin = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
        >>> notification = Notification(u'hey!', datetime.date(2020, 10, 01))
        >>> meta.Session.add(notification)
        >>> meta.Session.commit()
        >>> res = meta.set_active_user(admin.id)
        >>> print notification.id
        1

        >>> len(notification.users)
        0

        >>> notification = None
        >>> notification = meta.Session.query(Notification).first()
        >>> notification.content
        u'hey!'
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
