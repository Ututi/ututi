import logging

from pylons.controllers.util import abort
from pylons import request

from ututi.lib.forums import make_forum_post
from ututi.lib.base import BaseController
from ututi.model import Group
from ututi.model import GroupMailingListMessage
from ututi.model import File
from ututi.model import meta
from ututi.model.mailing import MessageAlreadyExists

log = logging.getLogger(__name__)


class ReceivemailController(BaseController):

    def __before__(self):
        self.message_queue = []

    def _queueMessage(self, message):
        self.message_queue.append(message)

    def _sendQueuedMessages(self):
        for message in self.message_queue:
            message.send(message.group.recipients_mailinglist())

    def index(self):
        abort(500)
        md5_list = request.POST.getall("md5[]")
        mime_type_list = request.POST.getall("mime-type[]")
        file_name_list = request.POST.getall("filename[]")

        message_text = request.str_POST['Mail']
        message = GroupMailingListMessage.parseMessage(message_text)
        group = message.getGroup()
        author = message.getAuthor()

        if group is None:
            return "Silent bounce!"

        if not group.mailinglist_enabled:
            if author is not None and group.is_member(author):
                meta.Session.execute("SET ututi.active_user TO %d" % author.id)
                request.environ['repoze.who.identity'] = author.id
                if not group.forum_categories:
                    return 'Ok!'
                post = make_forum_post(author,
                                       message.getSubject(),
                                       message.getBody(),
                                       group.id,
                                       category_id=group.forum_categories[0].id,
                                       thread_id=None,
                                       controller='forum')
                meta.Session.add(post)
                meta.Session.commit()
                return 'Ok!'
            return "Silent bounce!"

        try:
            message = GroupMailingListMessage.fromMessageText(message_text)
        except MessageAlreadyExists:
            return "Ok!"

        if message is None:
            return "Silent bounce!"

        if message.author is not None:
            meta.Session.execute("SET ututi.active_user TO %d" % message.author.id)
            request.environ['repoze.who.identity'] = message.author.id
        else:
            meta.Session.execute("SET ututi.active_user TO ''")

        meta.Session.add(message)

        meta.Session.commit() # to keep message and attachment ids stable
        attachments = []
        for md5, mimetype, filename in zip(md5_list,
                                           mime_type_list,
                                           file_name_list):
            if message.author is not None:
                meta.Session.execute("SET ututi.active_user TO %d" % message.author.id)
                request.environ['repoze.who.identity'] = message.author.id
            else:
                meta.Session.execute("SET ututi.active_user TO ''")

            # XXX we are not filtering nonsense files like small
            # images, pgp signatures, vcards and html bodies yet.
            f = File(filename,
                     filename,
                     mimetype=mimetype,
                     md5=md5)
            f.parent = message
            meta.Session.add(f)
            attachments.append(f)
            meta.Session.commit() # to keep attachment ids stable

        message.attachments.extend(attachments)

        if not message.in_moderation_queue:
            # only send emails for messages that don't have to be
            # moderated first
            self._queueMessage(message)

        meta.Session.commit()
        # Only send actual emails if commit succeeds
        self._sendQueuedMessages()
        return "Ok!"
