from ututi.lib.base import BaseController
from pylons import config
from mimetools import choose_boundary

from ututi.model import meta
from ututi.model.mailing import GroupMailingListMessage
from ututi.lib.mailer import send_email



class MailinglistBaseController(BaseController):
    def _recipients(self, group):
        recipients = []
        for member in group.members:
            if not member.subscribed:
                continue
            for email in member.user.emails:
                if email.confirmed:
                    recipients.append(email.email)
                    break
        return recipients

    def _generateMessageId(self):
        host = config.get('mailing_list_host', '')
        return "%s@%s" % (choose_boundary(), host)

    def post_message(self, group, user, subject, message, reply_to=None):
        message = send_email(user.emails[0].email,
                             group.list_address,
                             subject,
                             message,
                             message_id=self._generateMessageId(),
                             send_to=self._recipients(group),
                             reply_to=reply_to,
                             list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(message)
        post.group = group
        meta.Session.commit()
        return post

