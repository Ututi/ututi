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
from ututi.lib.security import ActionProtector, check_crowds
from ututi.lib.mailinglist import post_message
from ututi.lib.forums import make_forum_post
from ututi.lib.fileview import FileViewMixin
from ututi.lib import helpers as h
from ututi.model.mailing import GroupMailingListMessage
from ututi.model.events import PageCreatedEvent
from ututi.model.events import MailinglistPostCreatedEvent
from ututi.model.events import FileUploadedEvent
from ututi.model.events import ForumPostCreatedEvent
from ututi.model.events import SubjectWallPostEvent
from ututi.model.events import Event, EventComment
from ututi.model.events import LocationWallPostEvent
from ututi.model import ContentItem
from ututi.model import WallPost
from ututi.model import ForumCategory, LocationTag
from ututi.model import ForumPost, Page, Subject, meta, Group


class MessageRcpt(validators.FormValidator):
    messages = {
        'invalid': _(u"The group is not specified."),
    }

    def validate_python(self, form_dict, state):
        group_id = form_dict.get('group_id')
        group = Group.get(int(group_id))
        if group is not None and group.is_member(c.user):
            form_dict['group'] = group
        else:
            raise Invalid(self.message('invalid', state),
                          form_dict, state,
                          error_dict={'group_id': Invalid(self.message('invalid', state), form_dict, state)})


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


class WallPostMessageValidator(Schema):
    message = String(not_empty=True)


class SubjectWallPostForm(Schema):
    """Validate subject wall post form"""
    allow_extra_fields = True
    post = validators.String(not_empty=True)
    subject_id = validators.Int(not_empty=True)


class LocationWallPostForm(Schema):
    allow_extra_fields = True
    post = validators.String(not_empty=True)
    location_id = validators.Int(not_empty=True)


class DeleteWallPostForm(Schema):
    allow_extra_fields = True
    wall_post_id = validators.Int(not_empty=True)


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
                self.form_result['group'],
                self.form_result['subject'],
                self.form_result['message'],
                self.form_result.get('category_id', None))
        return {'success': True,
                'evt': evt}

    @ActionProtector("user")
    @validate(schema=MessageForm())
    def send_message(self):
        self._send_message(
            self.form_result['group'],
            self.form_result['subject'],
            self.form_result['message'],
            self.form_result.get('category_id', None))
        h.flash(_('Message sent.'))
        self._redirect()

    def _send_message(self, group, subject, message, category_id=None):
        if not group.mailinglist_enabled:
            if category_id is None:
                category_id = group.forum_categories[0].id
            post = ForumPost(subject, message, category_id=category_id,
                             thread_id=None)
            meta.Session.add(post)
            meta.Session.commit()

            evt = meta.Session.query(ForumPostCreatedEvent).filter_by(post_id=post.id).one().wall_entry()
            return evt
        else:
            post = post_message(group, c.user, subject, message)
            evt = meta.Session.query(MailinglistPostCreatedEvent).filter_by(message_id=post.id).one().wall_entry()
            return evt

    @ActionProtector("user")
    @js_validate(schema=WallPostMessageValidator())
    @jsonify
    def send_wall_message_js(self):
        message = self.form_result.get('message')
        return {'success':True}

    @ActionProtector("user")
    @validate(schema=WallPostMessageValidator())
    def send_wall_message(self):
        message = self.form_result.get('message') 
        return True

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
        page = self._create_wiki_page(target,
                                      self.form_result['page_title'],
                                      self.form_result['page_content'])
        evt = meta.Session.query(PageCreatedEvent).filter_by(page_id=page.id).one().wall_entry()
        return {'success': True, 'evt': evt}

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
    @js_validate(schema=SubjectWallPostForm())
    def create_subject_wall_post(self):
        subject = Subject.get_by_id(self.form_result['subject_id'])
        self._create_wall_post(subject=subject,
                               content=self.form_result['post'])
        self._redirect()

    @ActionProtector("user")
    @js_validate(schema=SubjectWallPostForm())
    @jsonify
    def create_subject_wall_post_js(self):
        subject = Subject.get_by_id(self.form_result['subject_id'])
        post = self._create_wall_post(subject=subject,
                                      content=self.form_result['post'])
        evt = meta.Session.query(SubjectWallPostEvent).filter_by(object_id=post.id).one().wall_entry()
        return {'success': True, 'evt': evt}

    @ActionProtector("user")
    @validate(schema=LocationWallPostForm())
    def create_location_wall_post(self):
        location = LocationTag.get(self.form_result['location_id'])
        self._create_wall_post(location=location,
                               content=self.form_result['post'])
        self._redirect()

    @ActionProtector("user")
    @js_validate(schema=LocationWallPostForm())
    @jsonify
    def create_location_wall_post_js(self):
        location = LocationTag.get(self.form_result['location_id'])
        post = self._create_wall_post(location=location,
                                      content=self.form_result['post'])
        evt = meta.Session.query(LocationWallPostEvent).filter_by(object_id=post.id).one().wall_entry()
        return {'success': True, 'evt': evt}

    def _create_wall_post(self, subject=None, location=None, content=None):
        post = WallPost(subject=subject, location=location, content=content)
        meta.Session.add(post)
        meta.Session.commit()
        return post

    @ActionProtector("user")
    def remove_wall_post(self, id):
        self._remove_wall_post(id)
        self._redirect()

    def _remove_wall_post(self, wall_post_id):
        post = meta.Session.query(WallPost).filter_by(id=wall_post_id).one()
        if post and check_crowds(('owner', 'moderator'), c.user, post):
            post.deleted_by = c.user.id
            meta.Session.add(post)
            meta.Session.commit()
            return True
        else:
            return False

    @ActionProtector("user")
    def remove_comment(self, id):
        comment = EventComment.get(id)
        if comment:
            comment.deleted_by = c.user.id
            meta.Session.add(comment)
            meta.Session.commit()

        self._redirect()

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
                                   id=msg.id,
                                   author_id=msg.author_id if msg.author_id is not None else msg.author_or_anonymous,
                                   message=msg.body,
                                   created_on=msg.sent,
                                   attachments=msg.attachments,
                                   allow_comment_deletion=False)
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
                                   id=post.id,
                                   author_id=post.created.id,
                                   message=post.message,
                                   created_on=post.created_on,
                                   allow_comment_deletion=True)
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
                                   id=comment.id,
                                   author_id=comment.created.id,
                                   message=comment.content,
                                   created_on=comment.created_on,
                                   allow_comment_deletion=True)
        else:
            self._redirect()
