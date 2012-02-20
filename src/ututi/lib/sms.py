import logging

from datetime import datetime
from hashlib import md5
from paste.util.converters import asbool

from pylons.i18n import _
from pylons import config

from ututi.model import meta

log = logging.getLogger(__name__)

sms_queue = []

def send_sms(number, text, sender, recipient=None, parent=None):
    """Send sms using the vertex sms gateway."""
    from ututi.model import SMS
    msg = SMS(recipient_number=number,
              message_text=text,
              sender=sender,
              recipient=recipient)
    if parent:
        msg.outgoing_group_message = parent
    meta.Session.add(msg)
    log.debug("%s -> %r" % (number, text))

    hold_emails = asbool(config.get('hold_emails', False))
    if hold_emails:
        sms_queue.append((msg.recipient_number, msg.message_text))

def confirmation_request(user):
    hash = md5(datetime.now().isoformat() + str(user.phone_number)).hexdigest()
    hash = hash[:5]
    user.phone_confirmation_key = hash
    msg = _("Ututi registration code: %s") % hash
    send_sms(user.phone_number, msg, sender=user, recipient=user)


def sms_cost(text, n_recipients=1):
    text_length = len(text)
    ascii = True
    try:
        text.decode('utf8').encode('ascii')
    except UnicodeEncodeError:
        ascii = False

    # Please keep math in sync with the Javascript widget.
    # -----
    msg_length = text_length * (1 if ascii else 2)
    if msg_length <= 140:
        msgs = 1
    else:
        msgs = 1 + (msg_length - 1) // 134
    cost = n_recipients * msgs
    # -----
    return cost
