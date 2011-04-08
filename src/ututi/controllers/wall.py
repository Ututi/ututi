from pylons.decorators import validate
from pylons.decorators import jsonify
from pylons.controllers.util import abort
from pylons.controllers.util import redirect
from pylons import request
from pylons import tmpl_context as c
from pylons import url
from pylons.i18n import _
from pylons.templating import render_mako_def

from formencode.validators import String
from formencode.api import Invalid
from formencode.schema import Schema
from formencode import validators

from ututi.lib.base import BaseController
from ututi.lib.validators import js_validate, SubjectIdValidator
from ututi.lib.security import ActionProtector
from ututi.lib.mailinglist import post_message
from ututi.lib.forums import make_forum_post
from ututi.lib.fileview import FileViewMixin
from ututi.lib import helpers as h
from ututi.model.mailing import GroupMailingListMessage
from ututi.model.events import PageCreatedEvent
from ututi.model.events import MailinglistPostCreatedEvent
from ututi.model.events import FileUploadedEvent
from ututi.model.events import ForumPostCreatedEvent
from ututi.model.events import Event, EventComment
from ututi.model import GroupMember
from ututi.model import ContentItem
from ututi.model import ForumCategory
from ututi.model import ForumPost, Page, User, Subject, meta, Group


def _message_rcpt(term, current_user):
    """Return list of possible recipients limited by the query term."""

    classmates = meta.Session.query(User)\
        .filter(User.fullname.ilike('%%%s%%' % term))\
        .join(User.memberships)\
        .join(GroupMember.group)\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    users = []
    if len(classmates) == 0:
        users = meta.Session.query(User)\
            .filter(User.fullname.ilike('%%%s%%' % term))\
            .limit(10)\
            .all()

    return (classmates, users)


class MessageRcpt(validators.FormValidator):
    """
    Validate the universal message post form.
    Check if the recipient's id has been specified in the js field, if not,
    check if enough text has been input to identify the recipient.
    """
    messages = {
        'invalid': _(u"The recipient is not specified."),
    }

    def validate_python(self, form_dict, state):
        rcpt_group = form_dict.get('rcpt_group')
        rcpt_user = form_dict.get('rcpt_user_id')
        rcpt_name = form_dict.get('rcpt_user')

        rcpt_obj = None

        if rcpt_user:
            rcpt_obj = User.get(int(rcpt_user))
        elif rcpt_group and rcpt_group != 'select-pm':
            rcpt_obj = Group.get(int(rcpt_group))
            if not rcpt_obj.is_member(c.user):
                rcpt_obj = None
        elif rcpt_name:
            alternatives = _message_rcpt(rcpt_name, c.user)
            alternatives = alternatives[0] + alternatives[1]
            if alternatives:
                rcpt_obj = alternatives[0]

        if rcpt_obj is None:
            raise Invalid(self.message('invalid', state),
                          form_dict, state,
                          error_dict={'rcpt': Invalid(self.message('invalid', state), form_dict, state)})
        else:
            form_dict['recipient'] = rcpt_obj


class MessageForm(Schema):
    """Validate universal form for sending messages from the dashboard."""
    allow_extra_fields = True
    subject = validators.String(not_empty=True)
    message = validators.String(not_empty=True)
    chained_validators = [MessageRcpt()]


class WikiForm(Schema):
    """Validate universal form for creating wiki pages from the dashboard."""
    allow_extra_fields = True
    page_title = validators.UnicodeString(strip=True, not_empty=True)
    page_content = validators.UnicodeString(strip=True, not_empty=True)
    rcpt_wiki = SubjectIdValidator()


class WallReplyValidator(Schema):
    message = String(not_empty=True)


class WallController(BaseController, FileViewMixin):

    def _redirect(self):
        if request.referrer:
            redirect(request.referrer)
        else:
            redirect(url(controller='profile', action='feed'))


    @ActionProtector("user")
    def hide_event(self):
        """Hide an event from the user's wall, add the event ttype to the ignored events list."""
        etype = request.params.get('event_type')
        events = c.user.ignored_events_list
        events.append(etype)
        c.user.update_ignored_events(events)
        meta.Session.commit()
        if request.params.has_key('js'):
            return 'ok'
        else:
            self._redirect()

    @ActionProtector("user")
    @js_validate(schema=MessageForm())
    @jsonify
    def send_message_js(self):
        evt = self._send_message(
                self.form_result['recipient'],
                self.form_result['subject'],
                self.form_result['message'],
                self.form_result.get('category_id', None))
        return {'success': True,
                'evt': evt}

    @ActionProtector("user")
    @validate(schema=MessageForm())
    def send_message(self):
        self._send_message(
            self.form_result['recipient'],
            self.form_result['subject'],
            self.form_result['message'],
            self.form_result.get('category_id', None))
        h.flash(_('Message sent.'))
        self._redirect()

    def _send_message(self, recipient, subject, message, category_id=None):
        """ Send a message to the group.  """
        if isinstance(recipient, Group):
            if not recipient.mailinglist_enabled:
                if category_id is None:
                    category_id = recipient.forum_categories[0].id
                post = ForumPost(subject, message, category_id=category_id,
                                 thread_id=None)
                meta.Session.add(post)
                meta.Session.commit()

                evt = meta.Session.query(ForumPostCreatedEvent).filter_by(post_id=post.id).one().wall_entry()
                return evt
            else:
                post = post_message(recipient,
                                    c.user,
                                    subject,
                                    message)
                evt = meta.Session.query(MailinglistPostCreatedEvent).filter_by(message_id=post.id).one().wall_entry()
                return evt
        else:
            # Here was private message code
            raise NotImplementedError()

    @ActionProtector("user")
    def upload_file_js(self):
        target_id = request.params.get('target_id')
        target = None
        try:
            target_id = int(target_id)
            target = ContentItem.get(target_id)

            if isinstance(target, Group) and\
                    (not target.is_member(c.user)\
                         or not target.has_file_area\
                         or target.upload_status == target.LIMIT_REACHED):
                target = None

            if not isinstance(target, (Group, Subject)):
                target = None
        except ValueError:
            target = None

        if target is None:
            return 'UPLOAD_FAILED'

        f = self._upload_file_basic(target)
        if f is None:
            return 'UPLOAD_FAILED'
        else:
            evt = meta.Session.query(FileUploadedEvent).filter_by(file_id=f.id).one().wall_entry()
            return evt

    @ActionProtector("user")
    @js_validate(schema=WikiForm())
    @jsonify
    def create_wiki_js(self):
        target = Subject.get_by_id(self.form_result['rcpt_wiki'])
        page = self._create_wiki_page(
                 target,
                 self.form_result['page_title'],
                 self.form_result['page_content'])
        evt = meta.Session.query(PageCreatedEvent).filter_by(page_id=page.id).one().wall_entry()
        return {'success':True, 'evt': evt}

    @ActionProtector("user")
    @validate(schema=WikiForm())
    def create_wiki(self):
        if not hasattr(self, 'form_result'):
            self._redirect()

        target = Subject.get_by_id(self.form_result['rcpt_wiki'])
        self._create_wiki_page(
            target,
            self.form_result['page_title'],
            self.form_result['page_content'])
        h.flash(_('Wiki page created.'))
        self._redirect()

    def _create_wiki_page(self, target, title, content):
        page = Page(title, content)
        target.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        return page

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def mailinglist_reply(self, group_id, thread_id):
        try:
            group = Group.get(int(group_id))
            thread_id = int(thread_id)
        except ValueError:
            abort(404)
        thread = GroupMailingListMessage.get(thread_id, group.id)

        if group is None or thread is None:
            abort(404)

        last_post = thread.posts[-1]
        msg = post_message(group,
                            c.user,
                            u"Re: %s" % thread.subject,
                            self.form_result['message'],
                            reply_to=last_post.message_id)

        if request.params.has_key('js'):
            return render_mako_def('/sections/wall_entries.mako',
                                   'thread_reply',
                                   author_id=msg.author_id if msg.author_id is not None else msg.author_or_anonymous,
                                   message=msg.body,
                                   created_on=msg.sent,
                                   attachments=msg.attachments)
        else:
            self._redirect()

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def forum_reply(self, group_id, category_id, thread_id):
        try:
            group_id = int(group_id)
            group = Group.get(group_id)
        except ValueError:
            group = Group.get(group_id)
        try:
            thread_id = int(thread_id)
            category_id = int(category_id)
        except ValueError:
            abort(404)
        category = ForumCategory.get(category_id)
        thread = ForumPost.get(thread_id)

        if group is None or category is None or thread is None:
            abort(404)

        post = make_forum_post(c.user, thread.title, self.form_result['message'],
                               group_id=group.group_id, category_id=category_id,
                               thread_id=thread_id, controller='forum')

        thread.mark_as_seen_by(c.user)
        meta.Session.commit()
        if request.params.has_key('js'):
            return render_mako_def('/sections/wall_entries.mako',
                                   'thread_reply',
                                   author_id=post.created.id,
                                   message=post.message,
                                   created_on=post.created_on)
        else:
            self._redirect()

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def eventcomment_reply(self, event_id):
        event = Event.get(event_id)
        if event is None:
            abort(404)
        comment = EventComment(c.user, self.form_result['message'])
        event.post_comment(comment)
        meta.Session.commit()
        if request.params.has_key('js'):
            return render_mako_def('/sections/wall_entries.mako',
                                   'thread_reply',
                                   author_id=comment.created.id,
                                   message=comment.content,
                                   created_on=comment.created_on)
        else:
            self._redirect()

    @ActionProtector("user")
    @jsonify
    def message_rcpt_js(self):
        term = request.params.get('term', None)
        if term is None or len(term) < 1:
            return {'data' : []}

        (classmates, others) = _message_rcpt(term, c.user)

        classmates = [dict(label='%s (%s)' % (u.fullname, u.emails[0].email),
                           id=u.id) for u in classmates]
        users = [dict(label=u.fullname,
                      id=u.id) for u in others]
        return dict(data=classmates+users)
