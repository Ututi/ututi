import doctest
import ututi
from ututi.tests import UtutiLayer
from ututi.model import LocationTag, meta, User

def test_sms():
    """Test sms sending.

        >>> from ututi.lib.sms import send_sms, sms_queue
        >>> from ututi.model import SMS, User, meta

        >>> u = User.get('user@uni.ututi.com', LocationTag.get('uni'))
        >>> send_sms('+37061300034', u'Message text', u)
        >>> meta.Session.commit()

        >>> [(sms.message_text, sms.sending_status) for sms in meta.Session.query(SMS).all()]
        [(u'Message text', None)]

        >>> sms_queue.pop()
        ('+37061300034', u'Message text')

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup,
        tearDown=tear_down)
    suite.layer = UtutiLayer
    return suite

def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)

    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    meta.Session.add(uni)
    user = User(u'User', 'user@uni.ututi.com', uni, 'password')
    meta.Session.add(user)
    meta.Session.commit()

def tear_down(test):
    ututi.tests.tearDown(test)
