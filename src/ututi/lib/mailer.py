import logging
import os
from smtplib import SMTPRecipientsRefused
from smtplib import SMTP

from email.mime.multipart import MIMEMultipart
from email.Header import Header
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email.Utils import parseaddr, formataddr
from email import message_from_string, Encoders
from paste.util.converters import aslist
from paste.util.converters import asbool
from pylons import config

log = logging.getLogger(__name__)

mail_queue = []


class EmailInfo(object):

    def __init__(self, sender, recipients, message):
        self.sender, self.recipients, self.message = sender, recipients, message

    def payload(self):
        message = message_from_string(self.message)
        while message.is_multipart():
            message = message.get_payload()[0]
        return message.get_payload(decode=True)

    def __str__(self):
        return "<EmailInfo sender='%s' recipients=%s>" % (self.sender,
                                                          self.recipients)

    __repr__ = __str__


def compose_email(sender, recipient, subject, body, html_body=None,
                  message_id=None, reply_to=None, send_to=None, list_id=None, attachments=[]):

    # Header class is smart enough to try US-ASCII, then the charset we
    # provide, then fall back to UTF-8.
    header_charset = 'ISO-8859-1'

    # Split real name (which is optional) and email address parts
    sender_name, sender_addr = parseaddr(sender)
    recipient_name, recipient_addr = parseaddr(recipient)

    # We must always pass Unicode strings to Header, otherwise it will
    # use RFC 2047 encoding even on plain ASCII strings.
    sender_name = str(Header(unicode(sender_name), header_charset))
    recipient_name = str(Header(unicode(recipient_name), header_charset))

    # Make sure email addresses do not contain non-ASCII characters
    sender_addr = sender_addr.encode('ascii')
    recipient_addr = recipient_addr.encode('ascii')

    # We must choose the body charset manually
    for body_charset in 'US-ASCII', 'ISO-8859-1', 'UTF-8':
        try:
            body.encode(body_charset)
            if html_body is not None:
                html_body.encode(body_charset)
        except UnicodeError:
            pass
        else:
            break

    if body and html_body or attachments:
        if attachments:
            msg = MIMEMultipart()
        else:
            msg = MIMEMultipart('related')
        msg.preamble = 'This is a multi-part message in MIME format.'

        msgAlternative = MIMEMultipart('alternative')
        msg.attach(msgAlternative)

        msgText = MIMEText(body.encode(body_charset), 'plain', body_charset)
        msgAlternative.attach(msgText)
        msgAlternative['Content-Disposition'] = 'inline'

        if html_body:
            msgText = MIMEText(html_body.encode(body_charset), 'html', body_charset)
            msgAlternative.attach(msgText)
            msgAlternative['Content-Disposition'] = 'inline'
    else:
        # Create the message ('plain' stands for Content-Type: text/plain)
        msg = MIMEText(body.encode(body_charset), 'plain', body_charset)

    for f in attachments:
        part = MIMEBase('application', "octet-stream")
        part.set_payload(f['file'].read())
        Encoders.encode_base64(part)
        part.add_header('Content-Disposition', 'attachment; filename="%s"' % f['filename'])
        msg.attach(part)

    msg['From'] = formataddr((sender_name, sender_addr))
    msg['To'] = formataddr((recipient_name, recipient_addr))
    msg['Subject'] = Header(unicode(subject), header_charset)
    if message_id is not None:
        msg['Message-ID'] = "<%s>" % message_id
    if reply_to is not None:
        msg['In-reply-to'] = reply_to

    if list_id is not None:
        msg['Reply-To'] = list_id
        msg['Errors-To'] = config.get('email_to', 'errors@ututi.lt')
        msg['List-Id'] = list_id

    return msg.as_string()


def send_email(sender, recipient, subject, body, html_body=None,
               message_id=None, reply_to=None, send_to=None, list_id=None,
               attachments=[]):
    """Send an email.

    All arguments should be Unicode strings (plain ASCII works as well).

    Only the real name part of sender and recipient addresses may contain
    non-ASCII characters.

    The email will be properly MIME encoded and delivered though SMTP to
    localhost port 25.  This is easy to change if you want something different.

    The charset of the email will be the first one out of US-ASCII, ISO-8859-1
    and UTF-8 that can represent all the characters occurring in the email.
    """
    msgstr = compose_email(sender, recipient, subject, body, html_body,
                           message_id, reply_to, send_to, list_id, attachments=attachments)

    if send_to is None:
        send_to = recipient

    log.debug(sender)
    log.debug(send_to)
    log.debug(msgstr)
    raw_send_email(sender, send_to, msgstr)
    return msgstr


def raw_send_email(sender, recipients, message):
    if isinstance(recipients, basestring):
        recipients = [recipients]

    hold_emails = asbool(config.get('hold_emails', False))

    force_emails_to = aslist(os.environ.get("ututi_force_emails_to", []), ',',
                             strip=True)
    force_emails_to = [e for e in force_emails_to if e]

    if hold_emails and force_emails_to:
        recipients = [address for address in recipients
                      if address in force_emails_to]
        if recipients:
            hold_emails = False

    log.debug("Recipients: %r" % recipients)
    log.debug("Hold emails: %r" % asbool(config.get('hold_emails', False)))
    # Send the message via SMTP to localhost:25
    if not hold_emails:
        # send the email if we are not told to hold it
        server = config.get('smtp_host', 'localhost')
        port = config.get('smtp_port', 25)
        smtp = SMTP(server, port)
        try:
            smtp.sendmail(config['ututi_email_from'], recipients, message)
        except SMTPRecipientsRefused:
            log.warn(sender)
            log.warn(recipients)
            log.warn(repr(message))
        finally:
            smtp.quit()
    else:
        mail_queue.append(EmailInfo(sender, recipients, message))
