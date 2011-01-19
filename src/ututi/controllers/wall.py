from pylons.decorators import validate
from pylons.decorators import jsonify
from pylons.controllers.util import abort
from pylons.controllers.util import redirect
from pylons import request
from pylons import tmpl_context as c
from pylons.i18n import _
from pylons.templating import render_mako_def

from formencode.validators import String
from formencode.api import Invalid
from formencode.schema import Schema
from formencode import validators

from ututi.lib.base import BaseController
from ututi.lib.validators import js_validate
from ututi.lib.security import ActionProtector
from ututi.lib.mailinglist import post_message
from ututi.lib.forums import make_forum_post
from ututi.lib.fileview import FileViewMixin
from ututi.lib.wall import _message_rcpt
from ututi.lib import helpers as h
from ututi.model.mailing import GroupMailingListMessage
from ututi.model.events import Event, EventComment
from ututi.model import ForumCategory
from ututi.model import ForumPost, PrivateMessage, Page, User, Subject, meta, Group

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
        recipient = form_dict['rcpt']
        recipient_id = form_dict['rcpt_id']

        rcpt_obj = None

        if recipient_id.startswith('g_'):
            try:
                id = int(recipient_id[2:])
                rcpt_obj = Group.get(id)
            except ValueError:
                rcpt_obj = None

        elif recipient_id.startswith('u_'):
            try:
                id = int(recipient_id[2:])
                rcpt_obj = User.get(id)
            except ValueError:
                rcpt_obj = None

        else:
            (groups, classmates, users) = _message_rcpt(recipient, c.user)
            collection = groups + classmates + users
            if len(collection) == 1:
                rcpt_obj = collection[0]

        #check for group membership
        if isinstance(rcpt_obj, Group):
            if not rcpt_obj.is_member(c.user):
                rcpt_obj = None

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

class SubjectIdValidator(validators.OneOf):
    """Validate subject id by list available in runtime."""
    messages = {
        'invalid': _("Invalid subject"),
        'notIn': _("Invalid subject"),
        }
    def validate_python(self, value, state):
        self.list = [str(s.id) for s in c.user.all_watched_subjects]
        super(SubjectIdValidator, self).validate_python(value, state)


class WikiForm(Schema):
    """Validate universal form for creating wiki pages from the dashboard."""
    allow_extra_fields = True
    page_title = validators.UnicodeString(strip=True, not_empty=True)
    page_content = validators.UnicodeString(strip=True, not_empty=True)
    wiki_rcpt_id = SubjectIdValidator()


class WallReplyValidator(Schema):
    message = String(not_empty=True)


class WallController(BaseController, FileViewMixin):

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
            redirect(request.referrer)

    @ActionProtector("user")
    @js_validate(schema=MessageForm())
    @jsonify
    def send_message_js(self):
        self._send_message(
            self.form_result['recipient'],
            self.form_result['subject'],
            self.form_result['message'],
            self.form_result.get('category_id', None))
        return {'success': True}

    @ActionProtector("user")
    @validate(schema=MessageForm())
    def send_message(self):
        self._send_message(
            self.form_result['recipient'],
            self.form_result['subject'],
            self.form_result['message'],
            self.form_result.get('category_id', None))
        h.flash(_('Message sent.'))
        redirect(request.referrer)

    def _send_message(self, recipient, subject, message, category_id=None):
        """
        Send a message to the recipient. The recipient is either a group or a user.
        Message type is chosen accordingly.
        """
        if isinstance(recipient, Group):
            if not recipient.mailinglist_enabled:
                if category_id is None:
                    category_id = recipient.forum_categories[0].id
                post = ForumPost(subject, message, category_id=category_id,
                                 thread_id=None)
                meta.Session.add(post)
                meta.Session.commit()
                return post
            else:
                post = post_message(recipient,
                                    c.user,
                                    subject,
                                    message)
                return post
        elif isinstance(recipient, User):
            msg = PrivateMessage(c.user,
                                 recipient,
                                 subject,
                                 message)
            meta.Session.add(msg)
            meta.Session.commit()
            return msg

    @ActionProtector("user")
    def upload_file_js(self):
        target_id = request.params.get('target_id')
        target = None
        if target_id.startswith('g_'):
            target = Group.get(int(target_id[2:]))
            if not target.is_member(c.user):
                target = None
        elif target_id.startswith('s_'):
            target = Subject.get_by_id(int(target_id[2:]))

        if target is None:
            return 'UPLOAD_FAILED'

        return self._upload_file(target)

    @ActionProtector("user")
    @js_validate(schema=WikiForm())
    @jsonify
    def create_wiki_js(self):
        target = Subject.get_by_id(self.form_result['wiki_rcpt_id'])
        self._create_wiki_page(
            target,
            self.form_result['page_title'],
            self.form_result['page_content'])
        return dict(success=True)

    @ActionProtector("user")
    @validate(schema=WikiForm())
    def create_wiki(self):
        target = Subject.get_by_id(self.form_result['wiki_rcpt_id'])
        self._create_wiki_page(
            target,
            self.form_result['page_title'],
            self.form_result['page_content'])
        h.flash(_('Wiki page created.'))
        redirect(request.referrer)

    def _create_wiki_page(self, target, title, content):
        page = Page(title, content)
        target.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        return page

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def mailinglist_reply(self, group_id, thread_id):
        group = Group.get(group_id)
        try:
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
                                   author=msg.author_or_anonymous,
                                   message=msg.body,
                                   created=msg.sent,
                                   attachments=msg.attachments)
        else:
            redirect(request.referrer)

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def forum_reply(self, group_id, category_id, thread_id):
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
                                   author=post.created,
                                   message=post.message,
                                   created=post.created_on)
        else:
            redirect(request.referrer)

    @ActionProtector("user")
    @validate(schema=WallReplyValidator())
    def privatemessage_reply(self, msg_id):
        original = PrivateMessage.get(msg_id)
        if original is None or not (c.user == original.sender or c.user == original.recipient):
            abort(404)

        recipient = original.sender if original.recipient.id == c.user.id else original.recipient
        original.is_read = True
        thread_id = original.thread_id or original.id
        msg = PrivateMessage(c.user, recipient, original.subject,
                             self.form_result['message'],
                             thread_id=thread_id)
        meta.Session.add(msg)
        # Make sure this thread is unhidden on both sides.
        original.hidden_by_sender = False
        original.hidden_by_recipient = False
        meta.Session.commit()
        if request.params.has_key('js'):
            return render_mako_def('/sections/wall_entries.mako',
                                   'thread_reply',
                                   author=msg.sender,
                                   message=msg.content,
                                   created=msg.created_on)
        else:
            redirect(request.referrer)

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
                                   author=comment.created,
                                   message=comment.content,
                                   created=comment.created_on)
        else:
            redirect(request.referrer)
