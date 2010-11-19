from ututi.lib.base import BaseController
from pylons import config
from mimetools import choose_boundary

from ututi.model import meta
from ututi.model.mailing import GroupMailingListMessage
from ututi.lib.mailer import raw_send_email
from ututi.lib.mailer import compose_email


class MailinglistBaseController(BaseController):

    def _generateMessageId(self):
        host = config.get('mailing_list_host', '')
        return "%s@%s" % (choose_boundary(), host)

    def post_message(self, group, user, subject, message, reply_to=None):
        msgstr = compose_email(user.emails[0].email,
                               group.list_address,
                               subject,
                               message,
                               message_id=self._generateMessageId(),
                               send_to=group.recipients_mailinglist(),
                               reply_to=reply_to,
                               list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(msgstr)
        post.group = group
        meta.Session.commit()
        if not post.in_moderation_queue:
            raw_send_email(user.emails[0].email, group.recipients_mailinglist(), msgstr)
        return post

