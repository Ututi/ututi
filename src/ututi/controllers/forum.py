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
from ututi.model import Group, Forum, ForumPost
from ututi.model import meta


def setup_title(group_id, forum_id):
    c.forum = Forum.get(forum_id)
    if c.forum is None:
        abort(404)
    if group_id is not None:
        c.group = c.forum.group
        c.group_id = c.group.group_id
    else:
        c.group_id = None

    # Make sure forum title and description are localized.
    # This is not the best place to do this, but I know no better way.
    fix_public_forum_metadata(c.forum)

    c.breadcrumbs = [{'title': c.forum.title,
                      'link': url.current(action='index', forum_id=c.forum.id)}]


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
        if c.group is None:
            abort(404)
        c.security_context = c.group
        return method(self, id)
    return _group_action


def forum_action(method):
    def _forum_action(self, id, forum_id):
        if id is not None:
            group = Group.get(id)
            if group is None:
                abort(404)
            c.security_context = group
        setup_title(id, forum_id)
        return method(self, forum_id)
    return _forum_action


def forum_thread_action(method):
    def _forum_thread_action(self, id, forum_id, thread_id):
        c.thread_id = thread_id
        try:
            c.thread = meta.Session.query(ForumPost
                              ).filter_by(id=thread_id, forum_id=forum_id
                              ).one()
        except NoResultFound:
            abort(404)
        setup_title(id, forum_id)
        return method(self, forum_id, thread_id)
    return _forum_thread_action


class NewCategoryForm(Schema):

    title = validators.UnicodeString(not_empty=True, strip=True)
    description = validators.UnicodeString(not_empty=True, strip=True)


class NewReplyForm(Schema):

    allow_extra_fields = True

    message = validators.UnicodeString(not_empty=True, strip=True)


class NewTopicForm(NewReplyForm):

    title = validators.UnicodeString(not_empty=True, strip=True)


class ForumController(BaseController):

    def _top_level_messages(self, forum_id):
        messages = meta.Session.query(ForumPost)\
            .filter_by(forum_id=forum_id)\
            .filter(ForumPost.id == ForumPost.thread_id)\
            .order_by(desc(ForumPost.created_on)).all()

        threads = []
        for message in messages:
            thread = {}

            thread['thread_id'] = message.thread_id
            thread['title'] = message.title

            replies = meta.Session.query(ForumPost)\
                .filter_by(thread_id=message.thread_id)\
                .order_by(ForumPost.created_on).all()

            thread['reply_count'] = len(replies) - 1
            thread['created'] = replies[-1].created_on
            thread['author'] = replies[-1].created
            threads.append(thread)

        return sorted(threads, key=lambda t: t['created'], reverse=True)

    @group_action
    @ActionProtector("user")
    def list(self, id):
        return render('forum/list.mako')

    @forum_action
    @ActionProtector("user")
    def index(self, forum_id):
        c.forum_posts = self._top_level_messages(forum_id)
        return render('forum/index.mako')

    @forum_thread_action
    @ActionProtector("user")
    def thread(self, forum_id, thread_id):
        c.forum_posts = meta.Session.query(ForumPost)\
            .filter_by(forum_id=forum_id, thread_id=thread_id)\
            .order_by(ForumPost.created_on).all()
        return render('forum/thread.mako')

    @forum_thread_action
    @validate(NewReplyForm)
    @ActionProtector("user")
    def reply(self, forum_id, thread_id):
        post = ForumPost(c.thread.title,
                         self.form_result['message'],
                         forum_id=forum_id,
                         thread_id=thread_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect_to(controller='forum',
                    action='thread',
                    forum_id=forum_id,
                    thread_id=thread_id)

    def _new_thread_form(self):
        return render('forum/new.mako')

    @forum_action
    @ActionProtector("user")
    def new_thread(self, forum_id):
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
        forum = Forum(self.form_result['title'],
                      description=self.form_result['description'],
                      group=c.group)
        meta.Session.add(forum)
        meta.Session.commit()
        redirect_to(controller='forum', action='index', id=id, forum_id=forum.id)

    @forum_action
    @validate(NewTopicForm, form='_new_thread_form')
    @ActionProtector("user")
    def post(self, forum_id):
        post = ForumPost(self.form_result['title'],
                         self.form_result['message'],
                         forum_id=forum_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect(url.current(action='thread', thread_id=post.id))

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
