import logging

from formencode.validators import Email as EmailValidator, Int as IntValidator
from formencode.api import Invalid

from pylons import config

from ututi.lib.mailer import send_email
from ututi.lib.gg import send_message as send_gg
from ututi.lib.sms import send_sms


log = logging.getLogger(__name__)

class Message(object):
    """Base class for all message types."""

    def __init__(self, sender=None, parent=None, force=False, ignored_recipients=[]):
        self.sender = sender
        self.parent = parent
        self.force = force
        self.ignored_recipients = ignored_recipients

    def send(self, recipient):
        from ututi.model import User, Group

        if isinstance(recipient, list):
               #sending the message to a list of anythings
            for to in recipient:
                self.send(to)
        elif isinstance(recipient, User) or isinstance(recipient, Group):
            #send the message to a user
            #XXX the method of choosing the email of the user needs to be revised
            recipient.send(self)


class EmailMessage(Message):
    """Email message."""
    def __init__(self, subject, text, html=None, sender=None, force=False, ignored_recipients=[], attachments=[]):
        if sender is None:
            sender = config['ututi_email_from']

        super(EmailMessage, self).__init__(sender=sender, force=force, ignored_recipients=ignored_recipients)

        self.subject = subject
        self.text = text
        self.html = html
        self.attachments = attachments

    def send(self, recipient):
        if recipient in self.ignored_recipients:
            return
        if hasattr(self, "subject") and hasattr(self, "text"):
            if isinstance(recipient, basestring):
                try:
                    EmailValidator.to_python(recipient)
                    recipient.encode('ascii')
                    send_email(self.sender, recipient, self.subject, self.text,
                               html_body=self.html,
                               attachments=self.attachments)
                except (Invalid, UnicodeEncodeError):
                    log.debug("Invalid email %(email)s" % dict(email=recipient))
            else:
                Message.send(self, recipient=recipient)
        else:
            raise RuntimeError("The message must have a subject and a text to be sent.")


class GGMessage(Message):
    """A gadugadu message."""

    def __init__(self, text, force=False,  ignored_recipients=[]):
        self.text = text
        super(GGMessage, self).__init__(sender=None, force=force, ignored_recipients=ignored_recipients)

    def send(self, recipient):
        if recipient in self.ignored_recipients:
            return
        if type(recipient) in (basestring, int, long):
            try:
                IntValidator.to_python(recipient)
                send_gg(recipient, self.text)
            except Invalid:
                log.debug("Invalid gg number %(gg)s" % dict(gg=recipient))
        else:
            Message.send(self,recipient=recipient)


class SMSMessage(Message):
    """An SMS message."""

    def __init__(self, text, force=False, sender=None, parent=None, ignored_recipients=[]):
        self.text = text
        self.sender = sender
        self.recipient = None
        super(SMSMessage, self).__init__(sender=sender, parent=parent, force=force, ignored_recipients=ignored_recipients)

    def send(self, recipient):
        if recipient in self.ignored_recipients:
            return

        if isinstance(recipient, basestring):
            try:
                send_sms(recipient, self.text, self.sender, self.recipient,
                         parent=self.parent)
            except Invalid:
                log.debug("Invalid phone number %(num)s" % dict(num=recipient))
        else:
            Message.send(self, recipient=recipient)
