import logging

from formencode.validators import Email as EmailValidator

from ututi.lib.mailer import send_email
from pylons import config

log = logging.getLogger(__name__)

class Message(object):

    def __init__(self, subject, text, html=None, sender=None, force=False):
        if sender is None:
            self.sender = config['ututi_email_from']
        else:
            self.sender = sender
        self.subject = subject
        self.text = text
        self.html = html
        self.force = force

    def send(self, recipient):
        from ututi.model import User, Group
        if hasattr(self, "subject") and hasattr(self, "text"):
            if isinstance(recipient, list):
                #sending the message to a list of anythings
                for to in recipient:
                    self.send(to)
            elif isinstance(recipient, User) or isinstance(recipient, Group):
                #send the message to a user
                #XXX the method of choosing the email of the user needs to be revised
                recipient.send(self)
            elif isinstance(recipient, basestring):
                try:
                    #XXX : need to validate emails
                    EmailValidator.to_python(recipient)
                    send_email(self.sender, recipient, self.subject, self.text,
                               html_body=self.html)
                except:
                    log.debug("Invalid email %(email)s" % dict(email=recipient))
        else:
            raise RuntimeError("The message must have a subject and a text to be sent.")

