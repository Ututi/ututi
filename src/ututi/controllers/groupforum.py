#
from datetime import datetime

from sqlalchemy.sql.expression import desc
from formencode import Schema, validators

from pylons.decorators import validate
from pylons.controllers.util import redirect_to
from pylons.controllers.util import abort
from pylons import c, config

from mimetools import choose_boundary
from ututi.lib.mailer import send_email
from ututi.lib.base import render
from ututi.controllers.group import group_action
from ututi.controllers.group import GroupControllerBase
from ututi.model.mailing import GroupMailingListMessage
from ututi.model import Group, meta


def group_forum_action(method):
    def _group_action(self, id, thread_id):
        group = Group.get(id)
        if group is None:
            abort(404)
        thread = meta.Session.query(GroupMailingListMessage).filter_by(id=thread_id).first()
        if (thread is None or
            thread.thread != thread or
            thread.group != group):
            abort(404)
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group, thread)
    return _group_action


class NewReplyForm(Schema):
    """A schema for validating group edits."""

    allow_extra_fields = True

    message = validators.UnicodeString(not_empty=True, strip=True)


class NewMailForm(NewReplyForm):
    """A schema for validating group edits."""

    subject = validators.UnicodeString(not_empty=True, strip=True)


class GroupforumController(GroupControllerBase):


    def _top_level_messages(self, group):
        messages = []
        for message in meta.Session.query(GroupMailingListMessage)\
                .filter_by(group_id=group.id, reply_to=None)\
                .order_by(desc(GroupMailingListMessage.sent))\
                .all():
            msg = {'thread_id': message.id,
                   'last_reply_author_id': message.posts[-1].author.id,
                   'last_reply_author_title': message.posts[-1].author.fullname,
                   'last_reply_date': message.posts[-1].sent,
                   'reply_count': len(message.posts) - 1,
                   'subject': message.subject}
            messages.append(msg)
        return messages

    @group_action
    def index(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = self._top_level_messages(group)
        return render('forum/index.mako')

    @group_forum_action
    def thread(self, group, thread):
        c.group = group
        c.thread = thread
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = thread.posts
        return render('forum/thread.mako')

    @group_forum_action
    @validate(NewReplyForm)
    def reply(self, group, thread):
        last_post = thread.posts[-1]
        message = send_email(c.user.emails[0].email,
                             self._recipients(group),
                             u"Re: %s" % thread.subject,
                             self.form_result['message'],
                             message_id=self._generateMessageId(),
                             reply_to=last_post.message_id)
        post = GroupMailingListMessage.fromMessageText(message)
        post.group = group
        post.reply_to = last_post
        meta.Session.commit()
        redirect_to(controller='groupforum',
                    action='thread',
                    id=group.group_id, thread_id=thread.id)

    @group_action
    def new_thread(self, group):
        c.group = group
        return render('forum/new.mako')

    def _recipients(self, group):
        recipients = []
        for member in group.members:
            for email in member.user.emails:
                if email.confirmed:
                    recipients.append(email.email)
                    break
        return recipients

    def _generateMessageId(self):
        host = config.get('mailing_list_host', '')
        return "%s@%s" % (choose_boundary(), host)

    @group_action
    @validate(NewMailForm, form='new_thread')
    def post(self, group):
        message = send_email(c.user.emails[0].email,
                             self._recipients(group),
                             self.form_result['subject'],
                             self.form_result['message'],
                             self._generateMessageId())
        post = GroupMailingListMessage.fromMessageText(message)
        post.group = group
        meta.Session.commit()
        redirect_to(controller='groupforum',
                    action='thread',
                    id=group.group_id, thread_id=post.id)
