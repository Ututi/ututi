from ututi.lib.base import BaseController
from pylons import config
from mimetools import choose_boundary

from ututi.model import meta
from ututi.model.mailing import GroupMailingListMessage
from ututi.lib.mailer import raw_send_email
from ututi.lib.mailer import compose_email

def _generateMessageId():
    host = config.get('mailing_list_host', '')
    return "%s@%s" % (choose_boundary(), host)

def post_message(group, user, subject, message, reply_to=None, force=False, attachments=[]):
    msgstr = compose_email(user.email.email,
                           group.list_address,
                           subject,
                           message,
                           message_id=_generateMessageId(),
                           send_to=group.recipients_mailinglist(),
                           reply_to=reply_to,
                           list_id=group.list_address)
    post = GroupMailingListMessage.fromMessageText(msgstr, force=force)
    post.group = group
    if attachments:
        for attachment in attachments:
            attachment.parent = post
        post.attachments.extend(attachments)
    meta.Session.commit()
    if not post.in_moderation_queue:
        post.send(group.recipients_mailinglist())
    return post
