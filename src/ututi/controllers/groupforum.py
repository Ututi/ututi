#
from sqlalchemy.sql.expression import desc
from formencode import Schema, validators, htmlfill

from pylons.decorators import validate
from pylons.controllers.util import redirect_to
from pylons.controllers.util import abort
from pylons import url
from pylons import c, config

from mimetools import choose_boundary
from ututi.model import File
from ututi.lib.security import deny
from ututi.lib.security import check_crowds
from ututi.lib.security import ActionProtector
from ututi.lib.mailer import send_email
from ututi.lib.base import render
from ututi.controllers.files import serve_file
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
        c.security_context = group
        c.group = group
        c.object_location = group.location
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
                   'last_reply_author_id': message.posts[-1].author,
                   'last_reply_author_title': message.posts[-1].author.fullname,
                   'last_reply_date': message.posts[-1].sent,
                   'send': message.sent,
                   'author': message.author,
                   'reply_count': len(message.posts) - 1,
                   'subject': message.subject}
            messages.append(msg)
        return messages

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def index(self, group):
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = self._top_level_messages(group)
        return render('groupforum/index.mako')

    @group_forum_action
    @ActionProtector("member", "admin", "moderator")
    def thread(self, group, thread):
        c.thread = thread
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = thread.posts
        return render('groupforum/thread.mako')

    @group_forum_action
    @validate(NewReplyForm)
    @ActionProtector("member", "admin", "moderator")
    def reply(self, group, thread):
        last_post = thread.posts[-1]
        message = send_email(c.user.emails[0].email,
                             c.group.list_address,
                             u"Re: %s" % thread.subject,
                             self.form_result['message'],
                             message_id=self._generateMessageId(),
                             reply_to=last_post.message_id,
                             send_to=self._recipients(group),
                             list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(unicode(message))
        post.group = group
        post.reply_to = last_post
        meta.Session.commit()
        redirect_to(controller='groupforum',
                    action='thread',
                    id=group.group_id, thread_id=thread.id)

    def _new_thread_form(self):
        return render('groupforum/new.mako')

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def new_thread(self, group):
        return htmlfill.render(self._new_thread_form())

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

    @group_action
    @validate(NewMailForm, form='_new_thread_form')
    @ActionProtector("member", "admin", "moderator")
    def post(self, group):
        message = send_email(c.user.emails[0].email,
                             c.group.list_address,
                             self.form_result['subject'],
                             self.form_result['message'],
                             message_id=self._generateMessageId(),
                             send_to=self._recipients(group),
                             list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(unicode(message))
        post.group = group
        meta.Session.commit()
        redirect_to(controller='groupforum',
                    action='thread',
                    id=group.group_id, thread_id=post.id)

    def file(self, id, message_id, file_id):

        group = Group.get(id)
        if group is None:
            abort(404)

        message = meta.Session.query(GroupMailingListMessage).filter_by(id=message_id).first()
        if message is None:
            abort(404)

        file = File.get(file_id)
        if file is None:
            abort(404)

        # XXX kind of stupid to do this here
        if c.user is None:
            code = 401
        else:
            code = 403

        c.login_form_url = url(controller='home',
                               action='login',
                               came_from=file.url())
        if not check_crowds(['member', 'admin', 'moderator'], context=group):
            deny('Only group members can download attachments!', code)

        return serve_file(file)
