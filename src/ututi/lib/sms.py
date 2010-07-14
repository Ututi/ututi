import logging

from ututi.model import meta

log = logging.getLogger(__name__)

sms_queue = []

def send_sms(number, text, sender, recipient=None):
    """Send sms using the vertex sms gateway."""
    from ututi.model import SMS
    msg = SMS(recipient_number=number,
              message_text=text,
              sender=sender,
              recipient=recipient)
    meta.Session.add(msg)
