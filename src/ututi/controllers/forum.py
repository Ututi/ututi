from ututi.lib.base import BaseController

from mimetools import choose_boundary
from ututi.lib.mailer import send_email

from sqlalchemy.sql.expression import desc
from sqlalchemy.orm.exc import NoResultFound
from formencode.schema import Schema
from formencode import validators, htmlfill

from pylons.decorators import validate
from pylons.controllers.util import abort
from pylons.controllers.util import redirect, redirect
from pylons.i18n import _
from pylons import tmpl_context as c, url, config

from ututi.lib.security import ActionProtector
from ututi.lib.base import render
from ututi.lib.helpers import check_crowds, flash
from ututi.lib.security import deny
from ututi.controllers.group import GroupControllerBase, group_menu_items
from ututi.model import Group, ForumCategory, ForumPost, SubscribedThread
from ututi.model import get_supporters
from ututi.model import meta


def fix_public_forum_metadata(forum):
    if forum.group is not None:
        return
    assert forum.id in [1, 2], forum.id
    if forum.id == 1:
        title = _('Community page')
        description = _('Ututi community forum.')
    elif forum.id == 2:
        title = _('Ututi bugs')
        description = _('Report Ututi bugs here.')

    if forum.title != title:
        forum.title = title
        meta.Session.commit()
    if forum.description != description:
        forum.description = description
        meta.Session.commit()


def initialize_forum(group):
    if not meta.Session.query(ForumCategory).filter_by(group=group).count():
        category = ForumCategory(_('General'),
                                 _('Discussions on anything and everything'),
                                 group=group)
        meta.Session.add(category)
        meta.Session.commit()


class NewCategoryForm(Schema):

    title = validators.UnicodeString(not_empty=True, strip=True)
    description = validators.UnicodeString(not_empty=True, strip=True)


class NewReplyForm(Schema):

    allow_extra_fields = True

    message = validators.UnicodeString(not_empty=True, strip=True)


class EditPostForm(Schema):

    allow_extra_fields = True

    message = validators.UnicodeString(not_empty=True, strip=True)


class NewTopicForm(NewReplyForm):

    title = validators.UnicodeString(not_empty=True, strip=True)


def group_action(method):
    def _group_action(self, id=None):
        self.set_up_context(id=id)
        return method(self, id)
    return _group_action


def category_action(method):
    def _category_action(self, id=None, category_id=None):
        self.set_up_context(id=id, category_id=category_id)
        return method(self, id, category_id)
    return _category_action


def thread_action(method):
    def _thread_action(self, id=None, category_id=None, thread_id=None):
        self.set_up_context(id=id, category_id=category_id, thread_id=thread_id)
        return method(self, id, category_id, thread_id)
    return _thread_action


def protect_view(m):
    def fn(*args, **kwargs):
        if c.group is not None:
            if not c.group.forum_is_public and not check_crowds(['member', 'moderator']):
                deny("This forum is not public", 401)
        return m(*args, **kwargs)
    return fn


def protect_edit(m):
    def fn(*args, **kwargs):
        if c.group is not None:
            if not check_crowds(['member', 'moderator']):
                deny("Only members can post", 401)
        return m(*args, **kwargs)
    return fn


class ForumController(GroupControllerBase):

    controller_name = 'forum'

    def __before__(self):
        c.ututi_supporters = get_supporters()
        c.breadcrumbs = []
        c.controller = self.controller_name
        c.can_post = self.can_post

    def set_up_context(self, id=None, category_id=None, thread_id=None):
        if id is not None:
            c.group = Group.get(id)
            if c.group is None:
                abort(404)
            c.group_id = c.group.group_id
            c.group_menu_items = group_menu_items()
            if c.group.mailinglist_enabled:
                flash(_('The web-based forum for this group has been disabled.'
                        ' Please use the mailing list instead.'))
                redirect(url(controller='mailinglist', action='index', id=id))
            c.object_location = c.group.location
            c.security_context = c.group
            c.breadcrumbs.append({'title': c.group.title, 'link': c.group.url()})
            if category_id is None: # (crude optimization)
                initialize_forum(c.group)
        else:
            c.group = None
            c.group_id = None
            c.community_category = ForumCategory.get(1)
            c.bugs_category = ForumCategory.get(2)

        if category_id is not None:
            c.category = ForumCategory.get(category_id)
            if c.category is None:
                abort(404)
            c.breadcrumbs.append({'title': c.category.title,
                                  'link': url(controller=c.controller,
                              action='index', id=id, category_id=category_id)})
            # Make sure forum title and description are localized.
            # This is not the best place to do this, but I know no better way.
            fix_public_forum_metadata(c.category)
        else:
            c.category = None

        if thread_id is not None:
            c.thread = ForumPost.get(thread_id)
            if c.thread is None:
                abort(404)
            assert c.thread.category_id == int(c.category_id), repr(c.thread.category_id)
        else:
            c.thread = None

        if c.group is not None and self.can_post(c.user):
            # Only show tabs for members / people who can post.
            c.breadcrumbs.append(self._breadcrumb('forum'))

    @group_action
    @protect_view
    def categories(self, id):
        return render('forum/categories.mako')

    @category_action
    @protect_view
    def index(self, id, category_id):
        return render('forum/index.mako')

    @thread_action
    @protect_view
    def thread(self, id, category_id, thread_id):
        c.can_manage_post = self.can_manage_post
        c.forum_posts = meta.Session.query(ForumPost)\
            .filter_by(category_id=category_id,
                       thread_id=thread_id,
                       deleted_by=None)\
            .order_by(ForumPost.created_on).all()

        subscription = SubscribedThread.get(thread_id, c.user)
        c.subscribed = subscription and subscription.active

        c.first_unseen = c.thread.first_unseen_thread_post(c.user)
        c.thread.mark_as_seen_by(c.user)

        return render('forum/thread.mako')

    def _new_reply_form(self):
        return render('forum/thread.mako')

    @thread_action
    @validate(NewReplyForm, form='_new_reply_form')
    @ActionProtector("user")
    def reply(self, id, category_id, thread_id):
        self._post(c.thread.title, self.form_result['message'],
                   category_id=category_id, thread_id=thread_id)
        c.thread.mark_as_seen_by(c.user)
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=id,
                             category_id=category_id, thread_id=thread_id))

    def _new_thread_form(self):
        return render('forum/new_thread.mako')

    @category_action
    @ActionProtector("user")
    def new_thread(self, id, category_id):
        return htmlfill.render(self._new_thread_form())

    def _new_category_form(self):
        return render('forum/new_category.mako')

    @group_action
    @ActionProtector("admin", "moderator")
    def new_category(self, id):
        return htmlfill.render(self._new_category_form())

    @group_action
    @validate(NewCategoryForm, form='_new_category_form')
    @ActionProtector("admin", "moderator")
    def create_category(self, id):
        category = ForumCategory(self.form_result['title'],
                                 description=self.form_result['description'],
                                 group=c.group)
        meta.Session.add(category)
        meta.Session.commit()
        redirect(url(controller=c.controller, action='index', id=id, category_id=category.id))

    @category_action
    @validate(NewTopicForm, form='_new_thread_form')
    @ActionProtector("user")
    def post(self, id, category_id):
        post = self._post(title=self.form_result['title'],
                          message=self.form_result['message'],
                          category_id=c.category.id)
        redirect(url(controller=c.controller, action='thread', id=c.group_id,
                             category_id=c.category.id, thread_id=post.id))

    def _generateMessageId(self):
        host = config.get('mailing_list_host', '')
        return "%s@%s" % (choose_boundary(), host)

    def _post(self, title, message, category_id, thread_id=None):
        new_thread = thread_id is None

        post = ForumPost(title, message, category_id=category_id,
                         thread_id=thread_id)
        meta.Session.add(post)
        meta.Session.commit()

        meta.Session.refresh(post)
        thread = ForumPost.get(post.thread_id)
        subscription = SubscribedThread.get_or_create(post.thread_id, c.user,
                                                      activate=True)

        if c.group_id:
            if new_thread:
                # This is a new thread; automatically subscribe all interested
                # members.
                for member in c.group.members:
                    if member.subscribed_to_forum:
                        SubscribedThread.get_or_create(post.thread_id, member.user,
                                                       activate=True)

            forum_title = c.group.title
        else:
            forum_title = _('Community') if c.category.id == 1 else _('Bugs')

        extra_vars = dict(message=message, person_title=c.user.fullname, forum_title=forum_title,
            thread_url=url(controller=c.controller, action='thread',
                           id=c.group_id, category_id=c.category.id,
                           thread_id=post.thread_id, qualified=True))
        email_message = render('/emails/forum_message.mako',
                               extra_vars=extra_vars)

        recipients = set()
        for subscription in thread.subscriptions:
            if subscription.active:
                for email in subscription.user.emails:
                    if email.confirmed:
                        recipients.add(email.email)
                        break
            else:
                # Explicit unsubscription.
                for email in subscription.user.emails:
                    try:
                        recipients.remove(email.email)
                    except KeyError:
                        pass

        if recipients:
            re = 'Re: ' if not new_thread else ''
            send_email(config['ututi_email_from'],
                       config['ututi_email_from'],
                       '[%s] %s%s' % (c.group_id, re, title),
                       email_message,
                       message_id=self._generateMessageId(),
                       send_to=list(recipients))
        return post

    def _edit_post_form(self):
        return render('forum/edit.mako')

    _forum_posts = None

    def can_post(self, user):
        return user is not None and (not c.group_id or check_crowds(['member', 'admin', 'moderator']))

    def can_manage_post(self, post):
        if c.user is None:
            return False # Anonymous users can not change anything.
        if (check_crowds(['admin', 'moderator']) if c.group is not None
            else check_crowds(['root'])):
            return True # Moderator can edit/delete anything.

        if not post.created_by == c.user.id:
            return False # Not the owner.
        if not self._forum_posts: # Cache query result.
            self._forum_posts = meta.Session.query(ForumPost)\
                .filter_by(category_id=c.category.id,
                           thread_id=c.thread.thread_id,
                           deleted_by=None)\
                .order_by(ForumPost.created_on).all()
        if post.id != self._forum_posts[-1].id: # Not the last message in thread.
            # TODO: Show a flash warning that the message could not be edited.
            return False
        return True

    @thread_action
    @ActionProtector("user")
    def edit(self, id, category_id, thread_id):
        if not self.can_manage_post(c.thread):
            abort(403)
        return htmlfill.render(self._edit_post_form(),
                               defaults={'message': c.thread.message})

    @thread_action
    @validate(EditPostForm, form='_edit_post_form')
    @ActionProtector("user")
    def edit_post(self, id, category_id, thread_id):
        if self.can_manage_post(c.thread):
            c.thread.message = self.form_result['message']
            meta.Session.commit()
            flash(_("Post updated."))
        else:
            flash(_("Unable to edit post, probably because somebody has already replied to your post."))

        redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                     thread_id=c.thread.thread_id))

    @thread_action
    @ActionProtector("user")
    def delete_post(self, id, category_id, thread_id):
        if self.can_manage_post(c.thread):
            c.thread.deleted = c.user
            meta.Session.commit()
        else:
            flash(_("Unable to delete post, probably because somebody has already replied to your post."))
            redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                                 thread_id=c.thread.thread_id))

        if not c.thread.is_thread():
            flash(_("Post deleted."))
            redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                                 thread_id=c.thread.thread_id))
        else:
            flash(_("Thread deleted."))
            redirect(url(controller=c.controller, action='index', id=id, category_id=category_id))

    @thread_action
    @ActionProtector("user")
    def subscribe(self, id, category_id, thread_id):
        subscription = SubscribedThread.get_or_create(thread_id, c.user)
        subscription.active = True
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                             thread_id=c.thread.thread_id))

    @thread_action
    @ActionProtector("user")
    def unsubscribe(self, id, category_id, thread_id):
        subscription = SubscribedThread.get_or_create(thread_id, c.user)
        subscription.active = False
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                             thread_id=c.thread.thread_id))

    @category_action
    @ActionProtector("user")
    def mark_category_as_read(self, id, category_id):
       for forum_post in c.category.top_level_messages():
           forum_post['post'].mark_as_seen_by(c.user)
       redirect(url(controller=c.controller, action='index', id=id, category_id=category_id))

    # Redirects for backwards compatibility.

    def legacy_thread(self, id, thread_id):
        redirect(url(controller='mailinglist', action='thread',
                    id=id, thread_id=thread_id))

    def legacy_reply(self, id, thread_id):
        redirect(url(controller='mailinglist', action='reply',
                    id=id, thread_id=thread_id))

    def legacy_file(self, id, message_id, file_id):
        redirect(url(controller='mailinglist', action='file',
                    id=id, message_id=message_id, file_id=file_id))
