#
import re
from sqlalchemy.sql.expression import desc
from formencode import Schema, validators, htmlfill

from pylons.controllers.util import redirect
from pylons.controllers.util import abort
from pylons import url
from pylons import tmpl_context as c, config, request
from pylons.i18n import _
from pylons.templating import render_mako_def

from webhelpers import paginate

from mimetools import choose_boundary
from ututi.model import File
from ututi.lib.security import deny
from ututi.lib.security import check_crowds
from ututi.lib.security import ActionProtector
from ututi.lib.mailer import send_email
from ututi.lib.base import BaseController, render
from ututi.lib.validators import validate
from ututi.lib import helpers as h
from ututi.controllers.files import serve_file
from ututi.controllers.group import group_menu_items
from ututi.model.mailing import GroupMailingListMessage
from ututi.model import Group, meta


def check_forum_setting(group):
    if not group.mailinglist_enabled:
        h.flash(_('The mailing list for this group has been disabled.'
                  ' Please use the web-based forum instead.'))
        redirect(url(controller='forum', action='categories',
                     id=group.group_id))


def group_action(method):
    def _group_action(self, id=None):
        if id is None:
            redirect(url(controller='search', obj_type='group'))
        group = Group.get(id)
        if group is None:
            abort(404)
        check_forum_setting(group)
        c.security_context = group
        c.object_location = group.location
        c.group = group
        c.group_menu_items = group_menu_items()
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group)
    return _group_action


def set_login_url(method):
    def _set_login_url(self, group, message, file):
        c.login_form_url = url(controller='home',
                               action='login',
                               came_from=url(controller='mailinglist',
                                             action='thread',
                                             id=group.group_id,
                                             thread_id=message.thread.id,
                                             serve_file=file.id),
                               context=file.filename)
        return method(self, group, message, file)
    return _set_login_url


def group_mailinglist_action(method):
    def _group_action(self, id, thread_id):
        group = Group.get(id)
        if group is None:
            abort(404)

        check_forum_setting(group)
        thread = meta.Session.query(GroupMailingListMessage).filter_by(
                    id=thread_id).first()
        if (thread is None or
            thread.thread != thread or
            thread.group != group):
            abort(404)
        c.security_context = group
        c.group = group
        c.object_location = group.location
        c.group_menu_items = group_menu_items()
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group, thread)
    return _group_action


def mailinglist_file_action(method):
    def _group_action(self, id, message_id, file_id):
        group = Group.get(id)
        if group is None:
            abort(404)

        message = meta.Session.query(GroupMailingListMessage).filter_by(id=message_id).first()
        if message is None:
            abort(404)

        if isinstance(file_id, basestring):
            file_id = re.search(r"\d*", file_id).group()
        file = File.get(file_id)
        if file is None:
            #not in group.files: ??? are mailing list files added as the group's files?
            abort(404)

        c.security_context = group
        c.object_location = group.location
        c.group = group
        c.group_menu_items = group_menu_items()
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group, message, file)
    return _group_action


def protect_view(m):
    def fn(*args, **kwargs):
        if not (c.group.forum_is_public or check_crowds(['member', 'admin'])):
            deny("This mailing list is not public", 401)
        return m(*args, **kwargs)
    return fn


class NewReplyForm(Schema):
    """A schema for validating group edits."""

    allow_extra_fields = True

    message = validators.UnicodeString(not_empty=True, strip=True)


class NewMailForm(NewReplyForm):
    """A schema for validating group edits."""

    subject = validators.UnicodeString(not_empty=True, strip=True)


class MailinglistController(BaseController):

    @group_action
    @protect_view
    def index(self, group):
        message_objs = meta.Session.query(GroupMailingListMessage)\
            .filter_by(group_id=group.id, reply_to=None)\
            .order_by(desc(GroupMailingListMessage.sent))
        message_count = meta.Session.query(GroupMailingListMessage)\
            .filter_by(group_id=group.id, reply_to=None)\
            .order_by(desc(GroupMailingListMessage.sent))\
            .count()
        c.messages = paginate.Page(
                message_objs,
                page=int(request.params.get('page', 1)),
                item_count =  message_count,
                items_per_page = 20,
                )
        c.group_menu_current_item = 'mailinglist'
        if request.params.has_key('js'):
            return render_mako_def('mailinglist/index.mako', 'listThreads')
        return render('mailinglist/index.mako')

    @group_mailinglist_action
    @protect_view
    def thread(self, group, thread):
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file

        c.thread = thread
        c.group_menu_current_item = 'mailinglist'
        c.messages = thread.posts
        return render('mailinglist/thread.mako')

    @group_mailinglist_action
    @validate(NewReplyForm)
    @ActionProtector("member", "admin")
    def reply(self, group, thread):
        if hasattr(self, 'form_result'):
            last_post = thread.posts[-1]
            message = send_email(c.user.emails[0].email,
                                 c.group.list_address,
                                 u"Re: %s" % thread.subject,
                                 self.form_result['message'],
                                 message_id=self._generateMessageId(),
                                 reply_to=last_post.message_id,
                                 send_to=self._recipients(group),
                                 list_id=group.list_address)
            post = GroupMailingListMessage.fromMessageText(message)
            post.group = group
            post.reply_to = last_post
            meta.Session.commit()

        if request.params.has_key('js'):
            return _('Reply sent')

        redirect(url(controller='mailinglist',
                    action='thread',
                    id=group.group_id, thread_id=thread.id))

    def _new_thread_form(self):
        return render('mailinglist/new.mako')

    @group_action
    @ActionProtector("member", "admin")
    def new_thread(self, group):
        c.group_menu_current_item = 'mailinglist'
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
    @ActionProtector("member", "admin")
    def post(self, group):
        message = send_email(c.user.emails[0].email,
                             c.group.list_address,
                             self.form_result['subject'],
                             self.form_result['message'],
                             message_id=self._generateMessageId(),
                             send_to=self._recipients(group),
                             list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(message)
        post.group = group
        meta.Session.commit()
        redirect(url(controller='mailinglist',
                    action='thread',
                    id=group.group_id, thread_id=post.id))

    @mailinglist_file_action
    @set_login_url
    @ActionProtector('member', 'admin')
    def file(self, group, message, file):
        if c.user:
            c.user.download(file)
            meta.Session.commit()
        return serve_file(file)

    @group_action
    @ActionProtector('user')
    def new_anonymous_post(self, group):
        c.group_menu_current_item = 'mailinglist'
        return htmlfill.render(self._new_anonymous_post_form())

    def _new_anonymous_post_form(self):
        return render('mailinglist/new_anonymous_post.mako')

    @group_action
    @validate(NewMailForm, form='_new_anonymous_post_form')
    @ActionProtector("user")
    def post_anonymous(self, group):
        message = send_email(c.user.emails[0].email,
                             c.group.list_address,
                             self.form_result['subject'],
                             self.form_result['message'],
                             message_id=self._generateMessageId(),
                             send_to=self._recipients(group),
                             list_id=group.list_address)
        post = GroupMailingListMessage.fromMessageText(message)
        post.group = group
        meta.Session.commit()
        h.flash(_('Your message to the group was successfully sent.'))
        redirect(group.url())
