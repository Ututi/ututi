from pylons.decorators import validate
from pylons.decorators import jsonify
from pylons.controllers.util import redirect
from pylons import url
from pylons import request
from pylons import tmpl_context as c
from pylons.i18n import _

from formencode.api import Invalid
from formencode.foreach import ForEach
from formencode.schema import Schema
from formencode import validators
from formencode import htmlfill

from sqlalchemy.sql.expression import and_
from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import or_

from ututi.lib.base import render
from ututi.lib.events import event_types_grouped
from ututi.lib.validators import js_validate
from ututi.lib.security import ActionProtector
from ututi.lib.fileview import FileViewMixin
from ututi.lib.mailinglist import post_message
from ututi.lib import helpers as h
from ututi.model.events import Event
from ututi.model import ForumPost, PrivateMessage, Page, User, Subject, meta, GroupMember, Group

def _file_rcpt(current_user):
    """
    Return possible recipients for a file upload (for the current user).
    """
    groups = meta.Session.query(Group)\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .filter(Group.has_file_area == True)\
        .order_by(Group.title.asc())\
        .all()

    subjects = meta.Session.query(Subject)\
        .filter(Subject.id.in_([s.id for s in current_user.all_watched_subjects]))\
        .order_by(Subject.title.asc())\
        .all()
    return (groups, subjects)


def _message_rcpt(term, current_user):
    """
    Return possible message recipients based on the query term.

    The idea is to first search for groups and classmates (members of the groups the user belongs to).

    If these are not found, we search for all users in general, limiting the results to 10 items.
    """

    groups = meta.Session.query(Group)\
        .filter(or_(Group.group_id.ilike('%%%s%%' % term),
                    Group.title.ilike('%%%s%%' % term)))\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    classmates = meta.Session.query(User)\
        .filter(User.fullname.ilike('%%%s%%' % term))\
        .join(User.memberships)\
        .join(GroupMember.group)\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    users = []
    if len(groups) == 0 and len(classmates) == 0:
        users = meta.Session.query(User)\
            .filter(User.fullname.ilike('%%%s%%' % term))\
            .limit(10)\
            .all()

    return (groups, classmates, users)


class WallSettingsForm(Schema):
    allow_extra_fields = True
    filter_extra_fields = True
    events = ForEach(validators.String())


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


class WallMixin(FileViewMixin):

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
            redirect(self._redirect_url())

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
    @validate(schema=MessageForm(), form='feed')
    def send_message(self):
        self._send_message(
            self.form_result['recipient'],
            self.form_result['subject'],
            self.form_result['message'],
            self.form_result.get('category_id', None))
        h.flash(_('Message sent.'))
        redirect(self._redirect_url())

    def _send_message(self, recipient, subject, message, category_id=None):
        """
        Send a message to the recipient. The recipient is either a group or a user.
        Message type is chosen accordingly.
        """
        if isinstance(recipient, Group):
            if not recipient.mailinglist_enabled:
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
    @validate(schema=WikiForm(), form='feed')
    def create_wiki(self):
        target = Subject.get_by_id(self.form_result['wiki_rcpt_id'])
        self._create_wiki_page(
            target,
            self.form_result['page_title'],
            self.form_result['page_content'])
        h.flash(_('Wiki page created.'))
        redirect(self._redirect_url())

    def _create_wiki_page(self, target, title, content):
        page = Page(title, content)
        target.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        return page

    def _wall_settings_form(self):
        c.event_types = event_types_grouped(Event.event_types())
        return render('profile/wall_settings.mako')

    @ActionProtector("user")
    @validate(schema=WallSettingsForm, form='_wall_settings_form')
    def wall_settings(self):
        if hasattr(self, 'form_result'):
            events = set(self.form_result.get('events', []))
            events = list(set(Event.event_types()) - events)
            c.user.update_ignored_events(events)
            meta.Session.commit()
            h.flash(_('Your wall settings have been updated.'))
            redirect(self._redirect_url())

        defaults = {
            'events': list(set(Event.event_types()) - set(c.user.ignored_events_list))
            }

        return htmlfill.render(self._wall_settings_form(),
                               defaults=defaults)

    def _user_events(self):
        user_is_admin_of_groups = [membership.group_id
                                   for membership in c.user.memberships
                                   if membership.membership_type == 'administrator']
        return meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in c.user.all_watched_subjects]),
                        Event.object_id.in_([m.group.id for m in c.user.memberships]),
                        Event.recipient_id == c.user.id,
                        and_(Event.event_type=='private_message_sent',
                             Event.user == c.user)))\
            .filter(or_(Event.event_type != 'moderated_post_created',
                        Event.object_id.in_(user_is_admin_of_groups)))\
            .filter(~Event.event_type.in_(c.user.ignored_events_list))\
            .order_by(desc(Event.created))\
            .limit(20).all()

    @ActionProtector("user")
    @jsonify
    def message_rcpt_js(self):
        term = request.params.get('term', None)
        if term is None or len(term) < 1:
            return {'data' : []}

        (groups, classmates, others) = _message_rcpt(term, c.user)

        groups = [
            dict(label=_('Group: %s') % group.title,
                 id='g_%d' % group.id,
                 categories=[dict(value=cat.id, title=cat.title)
                             for cat in group.forum_categories]
                             if not group.mailinglist_enabled else [])
            for group in groups]

        classmates = [dict(label=_('Member: %s (%s)') % (u.fullname, u.emails[0].email),
                           id='u_%d'%u.id) for u in classmates]
        users = [dict(label=_('Member: %s') % (u.fullname),
                      id='u_%d' % u.id) for u in others]
        return dict(data=groups+classmates+users)

    def _file_rcpt(self):
        (groups, subjects) = _file_rcpt(c.user)

        items = []
        for group in groups:
            items.append(('g_%d' % group.id, _('Group: %s') % group.title))

        for subject in subjects:
            items.append(('s_%d' % subject.id, _('Subject: %s') % subject.title))
        return items

    def _wiki_rcpt(self):
        return [(subject.id, subject.title)
                for subject in c.user.all_watched_subjects]

    def _redirect_url(self):
        """This is the default redirect url of wall methods.
           Subclasses should override it."""
        return url(controller='profile', action='feed')
