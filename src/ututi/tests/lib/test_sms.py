from zope.testing import doctest
from ututi.tests import UtutiLayer

def test_sms():
    """Test sms sending.

        >>> from ututi.lib.sms import send_sms
        >>> from ututi.model import SMS, User, meta

        >>> u = User.get('admin@ututi.lt')
        >>> send_sms('+37061300034', u'Message text', u)
        >>> meta.Session.commit()

        >>> [(sms.message_text, sms.sending_status) for sms in meta.Session.query(SMS).all()]
        [(u'Message text', None)]
    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite
