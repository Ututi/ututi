from datetime import datetime

from pylons import request

from ututi.lib.base import BaseController
from ututi.lib.mailer import send_email
from ututi.model import SMS, meta

from pylons import config

class SmsController(BaseController):
    """SMS controller handling both dummy sms sending and sms status report reception."""

    def send(self):

        params = {
            'user': None,
            'password': None,
            'to': None,
            'from': None,
            'text': None,
            'dlr-url': None,
            'dlr-mask': None,
            'coding': None}

        text = ''
        for key in params.keys():
            text += "%s : %s \n" % (key, request.params.get(key, '-'))

        # simulate the delivery report
        import urllib2
        url = request.params.get('dlr-url')
        url = url.replace('%d', '1')
        url = url.replace('%T', '1279709763.685117')
        urllib2.urlopen(url)

        send_email(sender=config.get('ututi_email_from', 'info@ututi.lt'),
                   recipient=config.get('sms.dummy_send', 'info@ututi.lt'),
                   subject='SMS dummy send',
                   body=text)
        return '0;Message sent'

    def status(self):

        sms_id = request.params.get('id')
        sms = SMS.get(sms_id)
        sms.delivery_status = request.params.get('status')
        sms.delivered = datetime.utcnow()
        meta.Session.commit()
