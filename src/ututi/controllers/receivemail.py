from StringIO import StringIO
import logging
import mimetools
from routes.util import url_for
from nous.mailpost.MailBoxerTools import parseaddr
from nous.mailpost.MailBoxerTools import splitMail
from formencode import Schema, validators, Invalid, All

from pylons import request, response
from pylons.controllers.util import abort
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.mailer import raw_send_email
from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request
from ututi.model import GroupMailingListAttachment
from ututi.model import GroupMailingListMessage
from ututi.model import File
from ututi.model import meta, User, Email

log = logging.getLogger(__name__)


class ReceivemailController(BaseController):

    def __before__(self):
        self.message_queue = []

    def _queueMessage(self, *args):
        self.message_queue.append(args)

    def _sendQueuedMessages(self):
        for message in self.message_queue:
            self._composeMessage(*message)

    def _recipients(self):
        return [email.email for email in
                meta.Session.query(Email).filter_by(confirmed=True).all()]

    def _composeMessage(self, message, message_text, mime_message):
        headers_dict, body = splitMail(message_text.encode("utf-8"))
        headers = "".join(mime_message.headers)

        footer = ""
        for attachment in message.attachments:
            url = url_for(controller='files', action='get', id=attachment.file.id,
                          qualified=True)
            footer += '<a href="%s">%s</a>' % (url, attachment.file.title)
        new_message = "%s\r\n%s\r\n%s" % (headers, body, footer)
        raw_send_email(mime_message['From'], self._recipients(),  new_message)

    def index(self):
        md5_list = request.POST.getall("md5[]")
        mime_type_list = request.POST.getall("mime-type[]")
        file_name_list = request.POST.getall("filename[]")

        message_text = request.POST['Mail']
        mime_message = mimetools.Message(StringIO(message_text))
        headers_dict, body = splitMail(message_text.encode("utf-8"))
        author_name, author_address = parseaddr(mime_message['From'])
        author = User.get(author_address)
        if author is None:
            abort(404)

        if meta.Session.query(GroupMailingListMessage)\
                .filter_by(message_id=headers_dict['message-id'],
                           group_id="moderators").first():
            raise "XXX Test emails with duplicate msg ids"""
            return "OK!"

        message = GroupMailingListMessage()
        message.message_id = headers_dict['message-id']
        message.group_id = "moderators"
        message.body = body
        message.author = author
        meta.Session.add(message)

        attachments = []
        for md5, mimetype, filename in zip(md5_list,
                                           mime_type_list,
                                           file_name_list):
            f = File(filename,
                     filename,
                     mimetype=mimetype,
                     md5=md5)
            meta.Session.add(f)

            attachment = GroupMailingListAttachment()
            attachment.file = f
            attachment.message = message
            meta.Session.add(attachment)
            attachments.append(attachment)

        self._queueMessage(message, message_text, mime_message)
        meta.Session.commit()
        self._sendQueuedMessages()
        return "Ok!"
