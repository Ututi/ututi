import logging

from pylons import request
from pylons.controllers.util import abort
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController
from ututi.model import GroupMailingListAttachment
from ututi.model import GroupMailingListMessage
from ututi.model import File
from ututi.model import meta, Email
from ututi.model.mailing import MessageAlreadyExists

log = logging.getLogger(__name__)


class ReceivemailController(BaseController):

    def __before__(self):
        self.message_queue = []

    def _queueMessage(self, message):
        self.message_queue.append(message)

    def _sendQueuedMessages(self):
        for message in self.message_queue:
            message.send(self._recipients())

    def _recipients(self):
        return [email.email for email in
                meta.Session.query(Email).filter_by(confirmed=True).all()]

    def index(self):
        md5_list = request.POST.getall("md5[]")
        mime_type_list = request.POST.getall("mime-type[]")
        file_name_list = request.POST.getall("filename[]")

        message_text = request.POST['Mail']
        try:
            message = GroupMailingListMessage.fromMessageText(message_text)
        except MessageAlreadyExists:
            return "Ok!"

        if message.author is None:
            abort(404)

        meta.Session.add(message)

        attachments = []
        for md5, mimetype, filename in zip(md5_list,
                                           mime_type_list,
                                           file_name_list):

            # XXX we are not filtering nonsense files like small
            # images, pgp signatures, vcards and html bodies yet.
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

        self._queueMessage(message)
        meta.Session.commit()
        # Only send actual emails if commit succeeds
        self._sendQueuedMessages()
        return "Ok!"
