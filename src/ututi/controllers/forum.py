from formencode.schema import Schema
from formencode import validators, htmlfill

from ututi.lib.forums import make_forum_post
from ututi.lib.base import BaseController
from pylons.controllers.util import abort, redirect
from pylons import request, config
from pylons.i18n import _
from pylons import tmpl_context as c, url

from webhelpers import paginate

from ututi.lib.security import ActionProtector, check_crowds
from ututi.lib.base import render
from ututi.lib.helpers import flash
from ututi.lib.security import deny
from ututi.lib.validators import validate
from ututi.controllers.group import group_menu_items
from ututi.model import Group, ForumCategory, ForumPost, SubscribedThread
from ututi.model import meta


class CategoryForm(Schema):

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
        if c.thread is None:
            abort(404)
        return method(self, id, category_id, thread_id)
    return _thread_action


def protect_view(m):
    def fn(*args, **kwargs):
        if c.group is not None:
            if not c.group.forum_is_public and not check_crowds(['member', 'moderator']):
                deny("This forum is not public", 401)
            if c.group.mailinglist_enabled:
                flash(_('The web-based forum for this group has been disabled.'
                        ' Please use the mailing list instead.'))
                redirect(url(controller='mailinglist', action='index', id=c.group_id))

        return m(*args, **kwargs)
    return fn


def protect_edit(m):
    def fn(*args, **kwargs):
        if c.group is not None:
            if not check_crowds(['member', 'moderator']):
                deny("Only members can post", 401)
        return m(*args, **kwargs)
    return fn


class ForumController(BaseController):

    controller_name = 'forum'

    def __before__(self):
        c.breadcrumbs = []
        c.controller = self.controller_name
        c.can_post = self.can_post
        c.group_menu_current_item = 'forum'

    def set_up_context(self, id=None, category_id=None, thread_id=None):
        if id is not None:
            c.group = Group.get(id)
            if c.group is None:
                abort(404)
            c.group_id = c.group.group_id
            c.group_menu_items = group_menu_items()
            c.object_location = c.group.location
            c.security_context = c.group
            c.theme = c.group.location.get_theme()
            c.breadcrumbs.append({'title': c.group.title, 'link': c.group.url()})
        else:
            c.group = None
            c.group_id = None

        if category_id is not None:
            try:
                category_id = int(category_id)
            except ValueError:
                abort(404)
            c.category = ForumCategory.get(category_id)
            if c.category is None:
                abort(404)
            c.breadcrumbs.append({'title': c.category.title,
                                  'link': url(controller=c.controller,
                              action='index', id=id, category_id=category_id)})
        else:
            c.category = None

        if thread_id is not None:
            try:
                thread_id = int(thread_id)
            except ValueError:
                abort(404)
            c.thread = ForumPost.get(thread_id)
            if c.thread is None:
                abort(404)
            assert c.thread.category_id == int(c.category.id), repr(c.thread.category_id)
        else:
            c.thread = None

    @group_action
    @protect_view
    def categories(self, id):
        return render('forum/categories.mako')

    def _edit_category_form(self):
        return render('forum/edit_category.mako')

    @category_action
    @validate(CategoryForm, form='_edit_category_form')
    @protect_view
    def edit_category(self, id, category_id):
        if hasattr(self, 'form_result'):
            c.category.title = self.form_result['title']
            c.category.description = self.form_result['description']
            meta.Session.commit()
            redirect(url(controller=c.controller, action='categories',
                         id=c.group_id))
        return htmlfill.render(self._edit_category_form(),
                               defaults={'title': c.category.title,
                                         'description': c.category.description})

    @category_action
    @protect_view
    def delete_category(self, id, category_id):
        # This will not work if there are any threads in the category.
        meta.Session.delete(c.category)
        meta.Session.commit()
        redirect(url(controller=c.controller, action='categories',
                     id=c.group_id))

    @category_action
    @protect_view
    def index(self, id, category_id):

        c.threads = paginate.Page(
            c.category.top_level_messages(),
            url=url,
            page=int(request.params.get('page', 1)),
            items_per_page = 10,
            )

        return render('forum/index.mako')

    @thread_action
    @protect_view
    def thread(self, id, category_id, thread_id):
        c.thread_id = thread_id
        c.category_id = category_id
        c.can_manage_post = self.can_manage_post
        forum_posts = meta.Session.query(ForumPost)\
            .filter_by(category_id=category_id,
                       thread_id=thread_id,
                       deleted_by=None)\
            .order_by(ForumPost.created_on)
        c.forum_posts = paginate.Page(
            forum_posts,
            url=url,
            page=int(request.params.get('page', 1)),
            item_count = forum_posts.count(),
            items_per_page = 20,
            )

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
        make_forum_post(c.user, c.thread.title, self.form_result['message'],
                        group_id=c.group_id, category_id=category_id,
                        thread_id=thread_id, controller=c.controller)
        c.thread.mark_as_seen_by(c.user)
        meta.Session.commit()
        if request.params.has_key('js'):
            return _('Reply sent')

        redirect(url(controller=c.controller, action='thread', id=id,
                             category_id=category_id, thread_id=thread_id))

    def _new_thread_form(self):
        return render('forum/new_thread.mako')

    @category_action
    @ActionProtector("user")
    def new_thread(self, id, category_id):
        c.category_id = category_id
        return htmlfill.render(self._new_thread_form())

    def _new_category_form(self):
        return render('forum/new_category.mako')

    @group_action
    @ActionProtector("admin", "moderator")
    def new_category(self, id):
        return htmlfill.render(self._new_category_form())

    @group_action
    @validate(CategoryForm, form='_new_category_form')
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
        post = make_forum_post(user=c.user,
                               title=self.form_result['title'],
                               message=self.form_result['message'],
                               group_id=c.group_id, category_id=c.category.id,
                               controller=c.controller)
        redirect(url(controller=c.controller, action='thread', id=c.group_id,
                             category_id=c.category.id, thread_id=post.id))

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
