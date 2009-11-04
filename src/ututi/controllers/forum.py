from ututi.lib.base import BaseController

from sqlalchemy.orm.exc import NoResultFound
from formencode.schema import Schema
from formencode import validators, htmlfill

from pylons.decorators import validate
from pylons.controllers.util import abort
from pylons.controllers.util import redirect_to
from pylons.i18n import _
from pylons import tmpl_context as c, url

from ututi.lib.security import ActionProtector
from ututi.lib.base import render
from ututi.model import ForumPost
from ututi.model import meta

def setup_title(forum_id):
    c.forum_id = forum_id
    forum_titles = {'bugs': _('Report a bug'),
                    'community': _('Community page')}
    forum_logos = {'bugs': 'report_bug.png',
                   'community': 'community.png'}

    forum_descriptions = {'bugs': _("This is ututi bugs forum"),
                          'community': _("This is ututi community forum.")}

    c.forum_title = forum_titles[c.forum_id]
    c.forum_logo = forum_logos[c.forum_id]
    c.forum_description = forum_descriptions[c.forum_id]
    c.poster_count = 0
    c.bugs_forum_messages = meta.Session.query(ForumPost)\
        .filter_by(forum_id='bugs')\
        .filter(ForumPost.thread_id == ForumPost.id)\
        .limit(5).all()
    c.community_forum_messages = meta.Session.query(ForumPost)\
        .filter_by(forum_id='community')\
        .filter(ForumPost.thread_id == ForumPost.id)\
        .limit(5).all()

    c.post_count = meta.Session.query(ForumPost).filter_by(forum_id=forum_id).count() or 0
    c.topic_count = meta.Session.query(ForumPost)\
        .filter_by(forum_id=forum_id)\
        .filter(ForumPost.thread_id == ForumPost.id)\
        .count() or 0
    query = """select count(distinct content_items.created_by)
                   from content_items
                   join forum_posts on forum_posts.id = content_items.id
                   where forum_id = '%s'""" % forum_id
    c.poster_count = meta.Session.execute(query).scalar() or 0

    c.breadcrumbs = [{'title': c.forum_title, 'link': url(controller='forum', forum_id=c.forum_id)}]


def forum_action(method):
    def _forum_action(self, forum_id):
        setup_title(forum_id)
        return method(self, forum_id)
    return _forum_action


def forum_thread_action(method):
    def _forum_thread_action(self, forum_id, thread_id):
        c.thread_id = thread_id
        try:
            c.thread = meta.Session.query(ForumPost).filter_by(id=thread_id,
                                                               forum_id=forum_id).one()
        except NoResultFound:
            abort(404)
        setup_title(forum_id)
        return method(self, forum_id, thread_id)
    return _forum_thread_action


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
            .order_by(ForumPost.created_on).all()
        return [{'thread_id': message.thread_id,
                 'title': message.title,
                 'reply_count': meta.Session.query(ForumPost).filter_by(thread_id=message.thread_id).count() - 1,
                 'created': message.created_on,
                 'author': message.created}
                for message in messages]

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

    @forum_action
    @validate(NewTopicForm, form='_new_thread_form')
    @ActionProtector("user")
    def post(self, forum_id):
        post = ForumPost(self.form_result['title'],
                         self.form_result['message'],
                         forum_id=forum_id)
        meta.Session.add(post)
        meta.Session.commit()
        redirect_to(controller='forum',
                    action='thread',
                    forum_id=c.forum_id,
                    thread_id=post.id)
