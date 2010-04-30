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


def setup_title(group_id, category_id):
    c.category = ForumCategory.get(category_id)
    if c.category is None:
        abort(404)
    if group_id is not None:
        c.group = c.category.group
        c.group_id = c.group.group_id
    else:
        c.group_id = None

    # Make sure forum title and description are localized.
    # This is not the best place to do this, but I know no better way.
    fix_public_forum_metadata(c.category)

    c.breadcrumbs.append({'title': c.category.title,
                          'link': url.current(action='index', category_id=c.category.id)})


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


def group_action(method):
    def _group_action(self, id):
        c.group = Group.get(id)
        c.object_location = c.group.location
        c.breadcrumbs = [{'title': c.group.title, 'link': c.group.url()}]
        if c.group is None:
            abort(404)
        c.security_context = c.group
        return method(self, id)
    return _group_action


def category_action(method):
    def _forum_action(self, id, category_id):
        if id is not None:
            group = Group.get(id)
            c.object_location = group.location
            c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
            if group is None:
                abort(404)
            c.security_context = group
        setup_title(id, category_id)
        return method(self, category_id)
    return _forum_action


def forum_thread_action(method):
    def _forum_thread_action(self, id, category_id, thread_id):
        if id is not None:
            c.group = group = Group.get(id)
            c.object_location = group.location
            c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
            if group is None:
                abort(404)
            c.security_context = group
        else:
            c.group = None
        c.thread_id = thread_id
        try:
            c.thread = meta.Session.query(ForumPost
                              ).filter_by(id=thread_id, category_id=category_id
                              ).one()
        except NoResultFound:
            abort(404)
        setup_title(id, category_id)
        return method(self, category_id, thread_id)
    return _forum_thread_action


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


class ForumController(GroupControllerBase):

    def __before__(self):
        c.ututi_supporters = get_supporters()
        c.breadcrumbs = []

    @group_action
    @ActionProtector("user")
    def list(self, id):
        c.breadcrumbs.append(self._actions('forum'))
        return render('forum/categories.mako')

    @category_action
    @ActionProtector("user")
    def index(self, category_id):
        if c.group_id is not None:
            c.breadcrumbs.append(self._actions('forum'))
        return render('forum/index.mako')

    @forum_thread_action
    @ActionProtector("user")
    def thread(self, category_id, thread_id):
        c.forum_posts = meta.Session.query(ForumPost)\
            .filter_by(category_id=category_id, thread_id=thread_id)\
            .order_by(ForumPost.created_on).all()
        return render('forum/thread.mako')

    @forum_thread_action
    @validate(NewReplyForm)
    @ActionProtector("user")
    def reply(self, category_id, thread_id):
        post = ForumPost(c.thread.title,
                         self.form_result['message'],
                         category_id=category_id,
                         thread_id=thread_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect_to(controller='forum',
                    action='thread',
                    category_id=category_id,
                    thread_id=thread_id)

    def _new_thread_form(self):
        return render('forum/new.mako')

    @category_action
    @ActionProtector("user")
    def new_thread(self, category_id):
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
        redirect_to(controller='forum', action='index',
                    id=id, category_id=category.id)

    @category_action
    @validate(NewTopicForm, form='_new_thread_form')
    @ActionProtector("user")
    def post(self, category_id):
        post = ForumPost(self.form_result['title'],
                         self.form_result['message'],
                         category_id=category_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect(url.current(action='thread', thread_id=post.id))

    def _edit_post_form(self):
        return render('forum/edit.mako')

    @forum_thread_action
    @ActionProtector("user")
    def edit(self, category_id, thread_id):
        return htmlfill.render(self._edit_post_form(),
                               defaults={'message': c.thread.message})

    @forum_thread_action
    @validate(EditPostForm, form='_edit_post_form')
    @ActionProtector("user")
    def edit_post(self, category_id, thread_id):
        if not (c.thread.created_by == c.user.id or
          (check_crowds(['moderator']) if c.group is not None else check_crowds(['root']))):
            abort(403)
        c.thread.message = self.form_result['message']
        meta.Session.commit()
        redirect(url.current(action='thread',
                             thread_id=c.thread.thread_id))

    # Redirects for backwards compatibility.

    def legacy_thread(self, id, thread_id):
        redirect_to(controller='mailinglist', action='thread',
                    id=id, thread_id=thread_id)

    def legacy_file(self, id, thread_id):
        redirect_to(controller='mailinglist', action='file',
                    id=id, thread_id=thread_id)

    def legacy_reply(self, id, message_id, file_id):
        redirect_to(controller='mailinglist', action='reply',
                    id=id, message_id=message_id, file_id=file_id)
