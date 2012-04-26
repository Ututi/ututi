#
import re
from sqlalchemy.sql.expression import desc
from formencode import Schema, validators, htmlfill

from pylons.controllers.util import redirect
from pylons.controllers.util import abort
from pylons import url
from pylons import tmpl_context as c, request, response
from pylons.i18n import _
from pylons.templating import render_mako_def

from webhelpers import paginate

from ututi.model import File
from ututi.lib.security import deny
from ututi.lib.security import check_crowds
from ututi.lib.security import ActionProtector
from ututi.lib.base import render, BaseController
from ututi.lib.validators import validate, TranslatedEmailValidator
from ututi.lib.mailinglist import post_message
from ututi.lib import helpers as h
from ututi.controllers.files import serve_file
from ututi.controllers.group import group_menu_items
from ututi.model.mailing import GroupMailingListMessage
from ututi.model import GroupWhitelistItem
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
        c.theme = group.location.get_theme()
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
            thread.group != group):
            abort(404)

        if (thread.thread != thread and
            not thread.in_moderation_queue):
            abort(404)

        c.security_context = group
        c.group = group
        c.object_location = group.location
        c.group_menu_items = group_menu_items()
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        c.theme = group.location.get_theme()
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
        c.theme = group.location.get_theme()
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


class WhitelistEmailForm(Schema):
    """Schema that validates a single email field."""

    allow_extra_fields = True
    email = TranslatedEmailValidator(not_empty=True, strip=True)


class MailinglistController(BaseController):

    def _new_thread_form(self):
        return render('mailinglist/new.mako')

    @group_action
    @validate(NewMailForm, form='_new_thread_form')
    @ActionProtector("member", "admin")
    def post(self, group):
        post = post_message(group,
                            c.user,
                            self.form_result['subject'],
                            self.form_result['message'])
        redirect(url(controller='home',
                    action='feed'))
   
    @group_action
    @ActionProtector("member", "admin")
    def new_thread(self, group):
        return htmlfill.render(self._new_thread_form())

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
        post = post_message(group,
                            c.user,
                            self.form_result['subject'],
                            self.form_result['message'])
        h.flash(_('Your message to the group was successfully sent.'))
        redirect(group.url())

    @group_action
    @ActionProtector("admin")
    def administration(self, group):
        c.messages = meta.Session.query(GroupMailingListMessage)\
            .filter_by(group_id=group.id, in_moderation_queue=True)\
            .order_by(desc(GroupMailingListMessage.sent)).all()
        c.group_menu_current_item = 'mailinglist'
        response.cache_expires(seconds=0)
        return render('mailinglist/administration.mako')

    @group_mailinglist_action
    @ActionProtector("admin")
    def moderate_post(self, group, thread):
        if not thread.in_moderation_queue:
            redirect(thread.url())
        c.thread = thread
        c.group_menu_current_item = 'mailinglist'
        c.messages = thread.posts
        return render('mailinglist/moderate_post.mako')

    def _approve_post(self, group, thread, redirecturl=None, ajax=False):
        success = False
        if thread.in_moderation_queue:
            thread.approve()
            meta.Session.commit()
            success = True

        if ajax:
            if success:
                return render_mako_def('mailinglist/administration.mako',
                                       'approvedMessage')
            else:
                return render_mako_def('mailinglist/administration.mako',
                                       'warningMessage')

        if success:
            h.flash(_("Message %(link_to_message)s has been approved.") % {
                'link_to_message': h.link_to(thread.subject, thread.url())
            })
        else:
            h.flash(_("Could not approve %(link_to_message)s as it was already approved.") % {
                'link_to_message': h.link_to(thread.subject, thread.url())
            })

        if redirecturl is None:
            redirecturl = group.url(controller='mailinglist', action='administration')

        redirect(redirecturl)

    def _reject_post(self, group, thread, redirecturl=None, ajax=False):
        success = False
        if thread.in_moderation_queue:
            thread.reject()
            meta.Session.commit()
            success = True

        if ajax:
            if success:
                return render_mako_def('mailinglist/administration.mako',
                                       'rejectedMessage')
            else:
                return render_mako_def('mailinglist/administration.mako',
                                       'warningMessage')

        if success:
            h.flash(_("Message %(link_to_message)s has been rejected.") % {
                'link_to_message': h.link_to(thread.subject, thread.url())
            })
        else:
            h.flash(_("Could not reject %(link_to_message)s as it was already approved.") % {
                'link_to_message': h.link_to(thread.subject, thread.url())
            })

        if redirecturl is None:
            redirecturl = group.url(controller='mailinglist', action='administration')

        redirect(redirecturl)

    @group_mailinglist_action
    @ActionProtector("admin")
    def approve_post(self, group, thread):
        self._approve_post(group, thread)

    @group_mailinglist_action
    @ActionProtector("admin")
    def reject_post(self, group, thread):
        self._reject_post(group, thread)

    @group_mailinglist_action
    @ActionProtector("admin")
    def approve_post_from_list(self, group, thread):
        if request.params.has_key('js'):
            return self._approve_post(group, thread, ajax=True)
        else:
            return self._approve_post(group, thread, redirecturl=request.referrer)

    @group_mailinglist_action
    @ActionProtector("admin")
    def reject_post_from_list(self, group, thread):
        if request.params.has_key('js'):
            return self._reject_post(group, thread, ajax=True)
        else:
            return self._reject_post(group, thread, redirecturl=request.referrer)

    @group_action
    @validate(WhitelistEmailForm, form='administration')
    @ActionProtector("admin")
    def add_to_whitelist(self, group):
        if hasattr(self, 'form_result'):
            group.add_email_to_whitelist(self.form_result['email'])
            meta.Session.commit()
        redirect(group.url(controller='mailinglist', action='administration'))

    @group_action
    @validate(WhitelistEmailForm, form='administration')
    @ActionProtector("admin")
    def remove_from_whitelist(self, group):
        if hasattr(self, 'form_result'):
            for item in meta.Session.query(GroupWhitelistItem).filter_by(group_id=group.id,
                                                                         email=self.form_result['email']).all():
                meta.Session.delete(item)
                meta.Session.commit()
        redirect(group.url(controller='mailinglist', action='administration'))

    @group_action
    @ActionProtector("admin")
    def whitelist_js(self, group):
        return render_mako_def('mailinglist/administration.mako',
                               'group_whitelist', group=group)
