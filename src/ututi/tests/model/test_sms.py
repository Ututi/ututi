import doctest

from ututi.model import LocationTag
from ututi.model import SMS, User, meta
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

import ututi


def test_messages():
    """A simple test to see if the SNMS model works.

        >>> admin = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
        >>> sms = SMS(sender=admin, recipient=admin, recipient_number='+37060000000', message_text=u'Test message.')
        >>> meta.Session.add(sms)
        >>> meta.Session.commit()
        >>> res = meta.set_active_user(admin.id)

    The id should be assigned automatically:
        >>> sms.id
        1L

        >>> [(sms.message_text, sms.sending_status) for sms in meta.Session.query(SMS).all()]
        [(u'Test message.', None)]
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
