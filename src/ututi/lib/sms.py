import logging

from datetime import datetime
from ututi.model import meta
from hashlib import md5

from pylons.i18n import _

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


def confirmation_request(user):
    hash = md5(datetime.now().isoformat() + str(user.phone_number)).hexdigest()
    hash = hash[:5]
    user.phone_confirmation_key = hash
    msg = _("Ututi registration code: %s") % hash
    send_sms(user.phone_number, msg, sender=user, recipient=user)
