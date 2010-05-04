from ututi.lib.base import BaseController

from sqlalchemy.sql.expression import desc
from sqlalchemy.orm.exc import NoResultFound
from formencode.schema import Schema
from formencode import validators, htmlfill

from pylons.decorators import validate
from pylons.controllers.util import abort
from pylons.controllers.util import redirect, redirect_to
from pylons.i18n import _
from pylons import tmpl_context as c, url

from ututi.lib.security import ActionProtector
from ututi.lib.base import render
from ututi.lib.helpers import check_crowds
from ututi.controllers.group import GroupControllerBase
from ututi.model import Group, ForumCategory, ForumPost
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


def forum_url(controller='forum', **kwargs):
    return url(controller=controller, **kwargs)


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


class ForumController(GroupControllerBase):

    controller_name = 'forum'

    def __before__(self):
        c.ututi_supporters = get_supporters()
        c.breadcrumbs = []
        c.controller = self.controller_name

    def set_up_context(self, id=None, category_id=None, thread_id=None):
        if id is not None:
            c.group = Group.get(id)
            if c.group is None:
                abort(404)
            c.group_id = c.group.group_id
            if c.group.mailinglist_enabled:
                redirect_to(controller='mailinglist', action='index')
            c.object_location = c.group.location
            c.security_context = c.group
            c.breadcrumbs.append({'title': c.group.title, 'link': c.group.url()})
        else:
            c.group = None
            c.group_id = None

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

    @group_action
    @ActionProtector("user")
    def categories(self, id):
        c.breadcrumbs.append(self._actions('forum'))
        return render('forum/categories.mako')

    @category_action
    @ActionProtector("user")
    def index(self, id, category_id):
        return render('forum/index.mako')

    @thread_action
    @ActionProtector("user")
    def thread(self, id, category_id, thread_id):
        c.forum_posts = meta.Session.query(ForumPost)\
            .filter_by(category_id=category_id, thread_id=thread_id)\
            .order_by(ForumPost.created_on).all()
        return render('forum/thread.mako')

    @thread_action
    @validate(NewReplyForm)
    @ActionProtector("user")
    def reply(self, id, category_id, thread_id):
        post = ForumPost(c.thread.title,
                         self.form_result['message'],
                         category_id=category_id,
                         thread_id=thread_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=id,
                             category_id=category_id, thread_id=thread_id))

    def _new_thread_form(self):
        return render('forum/new.mako')

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
        post = ForumPost(self.form_result['title'],
                         self.form_result['message'],
                         category_id=c.category.id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=c.group_id,
                             category_id=c.category.id, thread_id=post.id))

    def _edit_post_form(self):
        return render('forum/edit.mako')

    @thread_action
    @ActionProtector("user")
    def edit(self, id, category_id, thread_id):
        return htmlfill.render(self._edit_post_form(),
                               defaults={'message': c.thread.message})

    @thread_action
    @validate(EditPostForm, form='_edit_post_form')
    @ActionProtector("user")
    def edit_post(self, id, category_id, thread_id):
        if not (c.thread.created_by == c.user.id or
          (check_crowds(['moderator']) if c.group is not None else check_crowds(['root']))):
            abort(403)
        c.thread.message = self.form_result['message']
        meta.Session.commit()
        redirect(url(controller=c.controller, action='thread', id=id, category_id=category_id,
                             thread_id=c.thread.thread_id))

    # Redirects for backwards compatibility.

    def legacy_thread(self, id, thread_id):
        redirect_to(controller='mailinglist', action='thread',
                    id=id, thread_id=thread_id)

    def legacy_reply(self, id, thread_id):
        redirect_to(controller='mailinglist', action='reply',
                    id=id, thread_id=thread_id)

    def legacy_file(self, id, message_id, file_id):
        redirect_to(controller='mailinglist', action='file',
                    id=id, message_id=message_id, file_id=file_id)
