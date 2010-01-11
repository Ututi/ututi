import re
import logging
from datetime import date
from os.path import splitext

from pkg_resources import resource_stream

from pylons import c, config, request, url
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate, jsonify
from pylons.i18n import _

from webhelpers import paginate

from formencode import Schema, validators, Invalid, variabledecode, htmlfill
from formencode.compound import Pipe
from formencode.foreach import ForEach

from formencode.variabledecode import NestedVariables

from sqlalchemy.sql.expression import not_
from sqlalchemy.orm.exc import NoResultFound

import ututi.lib.helpers as h
from ututi.lib.fileview import FileViewMixin
from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render, render_lang
from ututi.lib.validators import HtmlSanitizeValidator, LocationTagsValidator, TagsValidator

from ututi.model import LocationTag, User, GroupMember, GroupMembershipType, File
from ututi.model import meta, Group, SimpleTag, Subject, ContentItem, PendingInvitation, PendingRequest
from ututi.controllers.subject import SubjectAddMixin
from ututi.controllers.subject import NewSubjectForm
from ututi.controllers.search import SearchSubmit
from ututi.lib.security import is_root, check_crowds, deny
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query, search_query_count
from ututi.lib.emails import group_request_email, group_confirmation_email

log = logging.getLogger(__name__)


def _filter_watched_subjects(sids):
    """A modifier for the subjects query, which excludes subjects already being watched."""
    def _filter(query):
        return query.filter(not_(ContentItem.id.in_(sids)))
    return _filter


class GroupIdValidator(validators.FancyValidator):
    """A validator that makes sure the group id is unique."""

    messages = {
        'duplicate': _(u"Such id already exists, choose a different one."),
        'badId': _(u"Id cannot be used as an email address.")
        }

    def _to_python(self, value, state):
        return value.strip()

    def validate_python(self, value, state):
        if value != 0:
            g = Group.get(value)
            if g is not None:
                raise Invalid(self.message('duplicate', state), value, state)

            usernameRE = re.compile(r"^[^ \t\n\r@<>()\\/+]+$", re.I)
            if not usernameRE.search(value):
                raise Invalid(self.message('badId', state), value, state)


class FileUploadTypeValidator(validators.FancyValidator):
    """ A validator to check uploaded file types."""

    __unpackargs__ = ('allowed_types')

    messages = {
        'bad_type': _(u"Bad file type, only files of the types '%(allowed)s' are supported.")
        }

    def validate_python(self, value, state):
        if value is not None:
            if splitext(value.filename)[1].lower() not in self.allowed_types:
                raise Invalid(self.message('bad_type', state, allowed=', '.join(self.allowed_types)), value, state)


class LogoUpload(Schema):
    """A schema for validating logo uploads."""
    logo = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))


class GroupForm(Schema):
    """A schema for validating group edits and submits."""
    pre_validators = [NestedVariables()]

    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True)
    description = validators.UnicodeString()
    year = validators.String()

    moderators = validators.StringBoolean(if_missing=False)
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    logo_delete = validators.StringBoolean(if_missing=False)
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

    chained_validators = [
        TagsValidator()
        ]

class GroupLiveSearchForm(Schema):
    """A schema for validating group edits and submits."""
    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    year = validators.String()
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())


class EditGroupForm(GroupForm):
    """A schema for validating group edits."""
    default_tab = validators.OneOf(['home', 'forum', 'members', 'files', 'subjects', 'page'])

class NewGroupForm(GroupForm):
    """A schema for validating new group forms."""

    pre_validators = [variabledecode.NestedVariables()]
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

    id = Pipe(validators.String(strip=True, min=4, max=20), GroupIdValidator())


class GroupAddingForm(Schema):
    allow_extra_fields = True


class GroupPageForm(Schema):
    allow_extra_fields = True
    page_content = HtmlSanitizeValidator()


class GroupInvitationActionForm(Schema):
    allow_extra_fields = True
    action = validators.OneOf(['accept', 'reject'])
    came_from = validators.URL(require_tld=False, )

class GroupRequestActionForm(Schema):
    allow_extra_fields = True
    action = validators.OneOf(['confirm', 'deny'])
    hash_code = validators.String(strip=True)

class GroupMemberUpdateForm(Schema):
    allow_extra_fields = True
    role = validators.OneOf(['administrator', 'member', 'not-member'])
    user_id = validators.Int()

class GroupInviteForm(Schema):
    """A schema for validating group member invitations"""
    allow_extra_fields = True
    emails = validators.UnicodeString(not_empty=False)

class GroupInviteCancelForm(Schema):
    """A schema for validating group member invitations"""
    allow_extra_fields = True
    email = validators.UnicodeString(not_empty=False)

def group_action(method):
    def _group_action(self, id):
        group = Group.get(id)
        if group is None:
            abort(404)
        c.security_context = group
        c.object_location = group.location
        c.group = group
        c.group_payment_month = int(config.get('group_payment_month', 1000))
        c.group_payment_quarter = int(config.get('group_payment_quarter', 2000))
        c.group_payment_halfyear = int(config.get('group_payment_halfyear', 3000))
        c.group_file_limit = int(config.get('group_file_limit', 200 * 1024 * 1024))
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group)
    return _group_action


class GroupControllerBase(BaseController):

    def __before__(self):
        c.breadcrumbs = []

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        bcs = [
            {'title': _("What's new?"),
             'link': url(controller='group', action='home', id=c.group.group_id),
             'selected': selected == 'home',
             'event': h.trackEvent(c.group, 'home', 'breadcrumb')},
            {'title': _('Forum'),
             'link': url(controller='group', action='forum', id=c.group.group_id),
             'selected': selected == 'forum',
             'event': h.trackEvent(c.group, 'forum', 'breadcrumb')},
            {'title': _('Members'),
             'link': url(controller='group', action='members', id=c.group.group_id),
             'selected': selected == 'members',
             'event': h.trackEvent(c.group, 'members', 'breadcrumb')},
            {'title': _('Files'),
             'link': url(controller='group', action='files', id=c.group.group_id),
             'selected': selected == 'files',
             'event': h.trackEvent(c.group, 'files', 'breadcrumb')},
            {'title': _('Subjects'),
             'link': url(controller='group', action='subjects', id=c.group.group_id),
             'selected': selected == 'subjects',
             'event': h.trackEvent(c.group, 'subjects', 'breadcrumb')},
            {'title': _('Page'),
             'link': url(controller='group', action='page', id=c.group.group_id),
             'selected': selected == 'page',
             'event': h.trackEvent(c.group, 'page', 'breadcrumb')},
            ]
        return bcs

class GroupController(GroupControllerBase, FileViewMixin, SubjectAddMixin):
    """Controller for group actions."""

    @group_action
    def index(self, group):
        if check_crowds(["member", "admin", "moderator"]):
            redirect_to(controller='group', action=c.group.default_tab, id=group.group_id)
        else:
            redirect_to(controller='group', action='home', id=group.group_id)

    def _set_home_variables(self, group):
        c.breadcrumbs.append(self._actions('home'))
        c.events = group.group_events
        c.has_to_invite_members = (len(group.members) == 1 and
                                   len(group.invitations) == 0)
        c.wants_to_watch_subjects = (len(group.watched_subjects) == 0 and
                                     group.wants_to_watch_subjects)

    @group_action
    def home(self, group):
        if check_crowds(["member", "admin", "moderator"]):
            if request.params.get('do_not_watch'):
                group.wants_to_watch_subjects = False
                meta.Session.commit()
            self._set_home_variables(group)
            return render('group/home.mako')
        else:
            c.breadcrumbs = [{'title': group.title,
                              'link': url(controller='group', action='home', id=c.group.group_id)}]

            return render('group/home_public.mako')

    @group_action
    @ActionProtector("admin", "moderator", "member")
    def welcome(self, group):
        self._set_home_variables(group)
        return render('group/welcome.mako')

    @group_action
    def request_join(self, group):
        if c.user is None:
            c.login_form_url = url(controller='home',
                                   action='login',
                                   came_from=group.url(action='request_join'),
                                   context_type='group_join')
            deny(_('You have to log in or register to request group membership.'), 401)

        request = PendingRequest.get(c.user, group)
        if request is None and not group.is_member(c.user):
            if c.user is not None and self._check_handshakes(group, c.user) == 'invitation':
                group.add_member(c.user)
                self._clear_requests(group, c.user)
                h.flash(_('You are now a member of the group %s!') % group.title)
            else:
                group.request_join(c.user)
                group_request_email(group, c.user)
                h.flash(_("Your request to join the group was forwarded to the group's administrators. Thank You!"))

            meta.Session.commit()

        elif group.is_member(c.user):
            h.flash(_("You already are a member of this group."))
        else:
            h.flash(_("Your request to join the group is still being processed."))

        redirect_to(controller='group', action='home', id=group.group_id)

    def _edit_page_form(self):
        return render('group/edit_page.mako')

    @group_action
    @ActionProtector("admin", "moderator", "member")
    def edit_page(self, group):
        c.breadcrumbs.append(self._actions('page'))
        defaults = {
            'page_content': c.group.page,
            'page_public': 'public' if c.group.page_public else ''
            }
        return htmlfill.render(self._edit_page_form(), defaults=defaults)

    @group_action
    @validate(schema=GroupPageForm, form='_edit_page_form')
    @ActionProtector("admin", "moderator", "member")
    def update_page(self, group):
        page_content = self.form_result['page_content']
        if page_content is None:
            page_content = ''
        group.page = page_content
        group.page_public =  (self.form_result.get('page_public', False) == 'public')
        meta.Session.commit()
        h.flash(_("The group's front page was updated."))
        redirect_to(controller='group', action='page', id=group.group_id)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def files(self, group):
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file

        c.breadcrumbs.append(self._actions('files'))

        return render('group/files.mako')

    def _add_form(self):
        current_year = date.today().year
        c.years = range(current_year - 12, current_year + 3)
        return render('group/add.mako')

    @validate(schema=GroupAddingForm, post_only = False, on_get = True)
    @ActionProtector("user")
    def add(self):
        #some initial date may be submitted as a get request
        if hasattr(self, 'form_result'):
            location = LocationTag.get(self.form_result.get('location', ''))
            if location is not None:
                location = dict([('location-%d' % n, tag)
                                 for n, tag in enumerate(location.hierarchy())])
            else:
                location = []
        else:
            location = []

        defaults = {
            'year': self.form_result.get('year',  '')
            }
        defaults.update(location)

        return htmlfill.render(self._add_form(), defaults=defaults)

    @validate(schema=NewGroupForm, form='_add_form')
    @ActionProtector("user")
    def new_group(self):
        if hasattr(self, 'form_result'):
            values = self.form_result

            group = Group(group_id=values['id'],
                          title=values['title'],
                          description=values['description'],
                          year=date(int(values['year']), 1, 1))

            tag = values.get('location', None)
            group.location = tag

            meta.Session.add(group)

            if values['logo_upload'] is not None:
                logo = values['logo_upload']
                group.logo = logo.file.read()

            group.add_member(c.user, admin=True)

            if is_root(c.user):
                group.moderators = values['moderators']

            meta.Session.commit()
            redirect_to(controller='group', action='invite_members_step', id=values['id'])
        else:
            redirect_to(controller='group', action='add')

    def _get_available_roles(self, member):
        roles = ({'type' : 'administrator', 'title' : _('Administrator')},
                 {'type' : 'member', 'title' : _('Member')},
                 {'type' : 'not-member', 'title': _('Leave group')})
        active_role = member.is_admin and 'administrator' or 'member'
        for role in roles:
            role['selected'] = role['type'] == active_role
        if member.is_admin and len(c.group.administrators) == 1:
            roles = [role for role in roles
                     if role['type'] == 'administrator']
        return roles

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def members(self, group):
        c.breadcrumbs.append(self._actions('members'))
        c.members = []
        for member in group.members:
            c.members.append({'roles': self._get_available_roles(member),
                              'user': member.user,
                              'title': member.user.fullname,
                              'last_seen': h.fmt_dt(member.user.last_seen),
                              })
        c.members.sort(key=lambda member: member['title'])
        if check_crowds(['admin', 'moderator'], context=group):
            return render('group/members_admin.mako')
        else:
            return render('group/members.mako')

    def _edit_form(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        c.tabs = [('home', _("What's new?")),
                  ('forum', _('Forum')),
                  ('members', _('Members')),
                  ('files', _('Files')),
                  ('subjects', _('Subjects')),
                  ('page', _('Page'))]

        return render('group/edit.mako')

    @group_action
    @ActionProtector("admin", "moderator")
    def edit(self, group):
        defaults = {
            'title': group.title,
            'description': group.description,
            'tags': ', '.join([tag.title for tag in c.group.tags]),
            'year': group.year.year,
            'default_tab': group.default_tab
            }

        tags = dict([('tagsitem-%d' % n, tag.title)
                     for n, tag in enumerate(c.group.tags)])

        defaults.update(tags)

        if group.location is not None:
            location = dict([('location-%d' % n, tag)
                             for n, tag in enumerate(group.location.hierarchy())])
        else:
            location = []

        defaults.update(location)

        c.breadcrumbs.append(self._actions('home'))

        return htmlfill.render(self._edit_form(), defaults=defaults)

    @group_action
    @validate(EditGroupForm, form='_edit_form')
    @ActionProtector("admin", "moderator")
    def update(self, group):
        values = self.form_result
        group.title = values['title']
        group.year = date(int(values['year']), 1, 1)
        group.description = values['description']
        group.default_tab = values['default_tab']

        if values['logo_delete']:
            group.logo = None

        if values['logo_upload'] is not None:
            logo = values['logo_upload']
            group.logo = logo.file.read()

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', []) if len(tag.strip()) < 250]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',') if len(tag.strip()) < 250]

        group.tags = []
        for tag in tags:
            group.tags.append(SimpleTag.get(tag))

        if not group.moderators or is_root(c.user):
            tag = values.get('location', None)
            group.location = tag

        if is_root(c.user):
            group.moderators = values['moderators']

        meta.Session.commit()
        h.flash(_('Group information and settings updated.'))

        redirect_to(controller='group', action='home', id=group.group_id)

    def logo(self, id, width=None, height=None):
        group = Group.get(id)
        if group.logo is not None:
            return serve_image(group.logo, width=width, height=height)
        else:
            stream = resource_stream("ututi", "public/images/details/icon_group_large.png").read()
            return serve_image(stream, width, height)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def upload_file(self, group):
        return self._upload_file(group)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def upload_file_short(self, group):
        return self._upload_file_short(group)


    @group_action
    @ActionProtector("member", "admin", "moderator")
    def create_folder(self, group):
        self._create_folder(group)
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("admin", "moderator")
    def delete_folder(self, group):
        self._delete_folder(group)
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def js_create_folder(self, group):
        return self._create_folder(group)

    @group_action
    @ActionProtector("admin", "moderator")
    def js_delete_folder(self, group):
        return self._delete_folder(group)

    def _getSubject(self):
        location_id = request.GET['subject_location_id']
        location = meta.Session.query(LocationTag).filter_by(id=location_id).one()
        subject_id = request.GET['subject_id']
        return Subject.get(location, subject_id)

    def _watch_subject(self, group):
        group.watched_subjects.append(self._getSubject())
        meta.Session.commit()

    def _unwatch_subject(self, group):
        group.watched_subjects.remove(self._getSubject())
        meta.Session.commit()

    @group_action
    @ActionProtector("admin", "moderator")
    def watch_subject(self, group):
        self._watch_subject(group)
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("admin", "moderator")
    def js_watch_subject(self, group):
        self._watch_subject(group)
        return render_mako_def('group/subjects.mako',
                               'subject_flash_message',
                               subject=self._getSubject()) +\
            render_mako_def('group/subjects.mako',
                            'watched_subject',
                            subject=self._getSubject(),
                            new = True)

    @group_action
    @ActionProtector("admin", "moderator")
    def unwatch_subject(self, group):
        self._unwatch_subject(group)
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("admin", "moderator")
    def js_unwatch_subject(self, group):
        self._unwatch_subject(group)
        return "OK"

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def add_subject_step(self, group):
        c.step = True
        return render('group/add_subject.mako')

    def _createSubject(self, group):
        if not hasattr(self, 'form_result'):
            redirect_to(group.url(action='add_subject_step'))

        subject = self._create_subject()
        meta.Session.flush()
        group.watched_subjects.append(subject)

        meta.Session.commit()

    @validate(schema=NewSubjectForm, form='add_subject_step')
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def create_subject_step(self, group):
        self._createSubject(group)
        redirect_to(group.url(action='subjects_step'))

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def add_subject(self, group):
        return render('group/add_subject.mako')

    @validate(schema=NewSubjectForm, form='add_subject')
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def create_subject(self, group):
        self._createSubject(group)
        redirect_to(group.url(action='subjects'))

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def subjects_step(self, group):
        c.step = True
        c.search_target = url(controller = 'group', action='subjects_step', id = group.group_id)
        return self._subjects(group)

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def subjects(self, group):
        c.breadcrumbs.append(self._actions('subjects'))
        c.list_open = request.GET.get('list', '') == 'open'
        return self._subjects(group)

    def _subjects(self, group):
        """
        The basis for views displaying all the subjects the group is already watching and allowing
        members to choose new subjects for the group.
        """
        if check_crowds(["admin", "moderator"]):
            c.search_target = url(controller = 'group', action='subjects', id = group.group_id)

            #retrieve search parameters
            c.text = self.form_result.get('text', '')

            if 'tagsitem' in self.form_result or 'tags' in self.form_result:
                c.tags = self.form_result.get('tagsitem', None)
                if c.tags is None:
                    c.tags = self.form_result.get('tags', None).split(', ')
            else:
                c.tags = c.group.location.hierarchy()
            c.tags = ', '.join(filter(bool, c.tags))

            sids = [s.id for s in group.watched_subjects]

            search_params = {}
            if c.text:
                search_params['text'] = c.text
            if c.tags:
                search_params['tags'] = c.tags
            search_params['obj_type'] = 'subject'

            query = search_query(extra=_filter_watched_subjects(sids), **search_params)
            if self.form_result != {}:
                c.searched = True

            if search_params != {}:
                c.results = paginate.Page(
                    query,
                    page=int(request.params.get('page', 1)),
                    item_count = search_query_count(query),
                    items_per_page = 10,
                    **search_params)

            return render('group/subjects.mako')
        else:
            return render('group/subjects_member.mako')

    @group_action
    @validate(schema=GroupInviteForm, form='members', post_only = False, on_get = True)
    @ActionProtector("member", "admin", "moderator")
    def invite_members(self, group):
        """Invite new members to the group."""
        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '').split()
            self._send_invitations(group, emails)
        redirect_to(controller='group', action='members', id=group.group_id)

    @group_action
    @validate(schema=GroupInviteCancelForm, form='members')
    @ActionProtector("admin", "moderator")
    def cancel_invitation(self, group):
        """Cancel and delete an invitation that was sent out to the user."""
        if hasattr(self, 'form_result'):

            email = self.form_result.get('email', '')
            invitation = meta.Session.query(PendingInvitation).filter(PendingInvitation.group == group)\
                .filter(PendingInvitation.email == email).first()
            if invitation is not None:
                meta.Session.delete(invitation)
                meta.Session.commit()
                h.flash(_('Invitation cancelled'))
        redirect_to(controller='group', action='members', id=group.group_id)

    @validate(schema=GroupInviteForm, form='invite_members_step')
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def invite_members_step(self, group):

        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '').split()
            self._send_invitations(group, emails)
            if self.form_result.get('final_submit', None) is not None:
                redirect_to(group.url(action='welcome'))
            else:
                redirect_to(controller='group', action='invite_members_step', id=group.group_id)

        return render('group/members_step.mako')

    def _clear_requests(self, group, user):
        """Delete any pending invitations or requests for the group with the given email."""
        request = meta.Session.query(PendingRequest).filter(PendingRequest.group == group)\
            .filter(PendingRequest.user == user).first()
        invitation = meta.Session.query(PendingInvitation).filter(PendingInvitation.group == group)\
            .filter(PendingInvitation.email == user.emails[0].email).first()
        if request is not None:
            meta.Session.delete(request)
        if invitation is not None:
            meta.Session.delete(invitation)

    def _check_handshakes(self, group, user):
        """Check if the user already has a request to join the group or an invitation"""
        request = meta.Session.query(PendingRequest).filter(PendingRequest.group == group)\
            .filter(PendingRequest.user == user).first()
        invitation = meta.Session.query(PendingInvitation).filter(PendingInvitation.group == group)\
            .filter(PendingInvitation.email == user.emails[0].email).first()
        return request is not None and 'request' or invitation is not None and 'invitation'

    def _send_invitations(self, group, emails):
        count = 0
        failed = []
        for line in emails:
            for email in filter(bool, line.split(',')):
                try:
                    validators.Email.to_python(email)
                    user = User.get(email)
                    if user is not None and self._check_handshakes(group, user) == 'request':
                        group.add_member(user)
                        self._clear_requests(group, c.user)
                        h.flash(_('New member %s added.') % user.fullname)
                    else:
                        count = count + 1
                        group.invite_user(email, c.user)
                except Invalid:
                    failed.append(email)
        if count > 0:
            h.flash(_("Users invited."))
        if failed != []:
            h.flash(_("Invalid email addresses detected: %s") % ', '.join(failed))
        meta.Session.commit()


    @validate(schema=GroupInvitationActionForm)
    @group_action
    def invitation(self, group):
        """Act on the invitation of the current user to this group."""
        if hasattr(self, 'form_result'):
            try:
                invitation = meta.Session.query(PendingInvitation).filter(PendingInvitation.group == group)\
                    .filter(PendingInvitation.user == c.user).one()
                if self.form_result.get('action', '') == 'accept':
                    group.add_member(c.user)
                    h.flash(_("Congratulations! You are now a member of the group '%s'") % group.title)
                else:
                    h.flash(_("Invitation to group '%s' rejected.") % group.title)

                self._clear_requests(group, c.user)
                meta.Session.commit()
            except NoResultFound:
                pass

            url = self.form_result.get('came_from', None)
            if url is None:
                redirect_to(controller='group', action='home', id=group.group_id)
            else:
                redirect_to(url.encode('utf-8'))
        else:
            redirect_to(controller='group', action='home', id=group.group_id)

    @validate(schema=GroupRequestActionForm)
    @group_action
    def request(self, group):
        if hasattr(self, 'form_result'):
            try:
                request = meta.Session.query(PendingRequest).filter_by(hash=self.form_result.get('hash_code', '')).one()
                if (self.form_result.get('action', 'deny') == 'confirm'):
                    c.group.add_member(request.user)
                    group_confirmation_email(group, request.user, True)
                    h.flash(_(u"New member %s added.") % request.user.fullname)
                else:
                    group_confirmation_email(group, request.user, False)
                    h.flash(_(u"Group membership denied to %s.") % request.user.fullname)

                #delete the request and any invitations
                self._clear_requests(group, request.user)
                meta.Session.commit()
            except NoResultFound:
                h.flash(_("Error confirming membership request."))
                pass

        url = self.form_result.get('came_from', None)
        if url is None:
            redirect_to(controller='group', action='members', id=c.group.group_id)
        else:
            redirect_to(url.encode('utf-8'))

    @validate(schema=GroupMemberUpdateForm)
    @group_action
    def update_membership(self, group):
        if hasattr(self, 'form_result'):
            user = User.get_byid(self.form_result.get('user_id', None))
            membership = GroupMember.get(user, group)
            if membership is not None:
                role = self.form_result.get('role', 'member')
                if role == 'not-member':
                    meta.Session.delete(membership)
                elif role in ['member', 'administrator']:
                    role = GroupMembershipType.get(role)
                    membership.role = role
                    h.flash(_("The status of the user %(fullname)s was updated.") % {'fullname': user.fullname})
                else:
                    h.flash(_("Problem updating the status of the user."))

                meta.Session.flush()
                meta.Session.expire(group)
                if group.administrators == 0:
                    h.flash(_('The group must have at least one administrator!'))
                    meta.Session.rollback()
                else:
                    meta.Session.commit()
            else:
                h.flash(_("Problem updating the status of the user. Cannot find such user."))
        redirect_to(controller="group", action="members", id=group.group_id)

    @group_action
    @validate(LogoUpload)
    @ActionProtector("user")
    def logo_upload(self, group):
        if self.form_result['logo'] is not None:
            logo = self.form_result['logo']
            group.logo = logo.file.read()
            meta.Session.commit()
            return ''

    @group_action
    @ActionProtector("admin")
    def do_delete(self, group):
        if len(group.members) > 1:
            redirect_to(controller='group', action='delete')


    @group_action
    @ActionProtector("admin")
    def delete(self, group):
        if len(group.members) > 1:
            h.flash(_("You can't delete a group while it has members!"))
            redirect_to(request.referrer)
        else:
            h.flash(_("Group '%(group_title)s' has been deleted!" % dict(group_title=group.title)))
            meta.Session.delete(group)
            meta.Session.commit()
            redirect_to(url(controller='profile', action='home'))

    @group_action
    @ActionProtector("member", "admin")
    def unsubscribe(self, group):
        membership = GroupMember.get(c.user, group)
        if membership is not None:
            membership.subscribed = False
        meta.Session.commit()
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("member", "admin")
    def subscribe(self, group):
        membership = GroupMember.get(c.user, group)
        if membership is not None:
            membership.subscribed = True
        meta.Session.commit()
        redirect_to(request.referrer)

    @group_action
    @ActionProtector("member", "admin")
    def leave(self, group):
        membership = GroupMember.get(c.user, group)
        if membership is not None:
            meta.Session.delete(membership)
            meta.Session.flush()
            meta.Session.expire(group)
        if len(group.administrators) < 1:
            h.flash(_('The group must have at least one administrator!'))
            meta.Session.rollback()
            redirect_to(request.referrer)
        meta.Session.commit()
        redirect_to(group.url())

    @group_action
    @ActionProtector("member", "admin")
    def page(self, group):
        c.breadcrumbs.append(self._actions('page'))
        return render('group/page.mako')

    @group_action
    @ActionProtector("user", "member", "admin")
    def set_receive_email_each(self, group):
        new_value = request.params.get('each')
        if  new_value in ('day', 'hour', 'never'):
            meta.Session.query(GroupMember)\
                .filter_by(user=c.user, group=group)\
                .one()\
                .receive_email_each = new_value
            meta.Session.commit()
        if request.params.get('ajax'):
            return 'OK'
        redirect_to(controller='profile', action='subjects')

    @validate(schema=GroupLiveSearchForm)
    def js_group_search(self):
        """Group live search in group creation view."""
        if hasattr(self, 'form_result'):
            location = self.form_result.get('location', None)
            year = self.form_result['year']
            groups = meta.Session.query(Group).filter(Group.location_id.in_([loc.id for loc in location.flatten]))
            if year != '':
                groups = groups.filter(Group.year == date(int(year), 1, 1))
            return render_mako_def('group/add.mako', 'live_search', groups = groups.all())
        else:
            abort(404)

    @jsonify
    @group_action
    @ActionProtector("admin", "moderator", "member")
    def file_info(self, group):
        """Information on the group's usage of the files area."""
        info = {
            'image' : render_mako_def('sections/files.mako', 'free_space_indicator', obj = group),
            'text' : render_mako_def('sections/files.mako', 'free_space_text', obj = group) }
        section_id = request.POST.get('section_id', None)
        if section_id is not None:
            info['section_id'] = section_id
        return info

    @jsonify
    @group_action
    @ActionProtector("admin", "moderator", "member")
    def upload_status(self, group):
        """
           Information on the group's file upload limits.
           1 - allow uploading, with folders
           2 - allow uploading, no folders
           0 - limit reached, no uploads
        """
        section_id = request.POST.get('section_id', None)

        return {'status' : group.upload_status, "section_id" : section_id}

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def pay(self, group):
        payment_forms = []
        payment_types = [_('month'), _('3 months'), _('6 months')]
        payment_amounts = [c.group_payment_month, c.group_payment_quarter, c.group_payment_halfyear]
        for amount in payment_amounts:
            payment_forms.append(h.mokejimai_form(
                    transaction_type='grouplimits',
                    amount=amount,
                    accepturl=group.url(action='pay_accept', qualified=True),
                    cancelurl=group.url(action='pay_cancel', qualified=True),
                    orderid='%s_%s_%s' % ('grouplimits', c.user.id, group.id)))
        c.payments = zip(payment_types, payment_amounts, payment_forms)
        c.breadcrumbs.append(self._actions('home'))
        return render_lang('group/pay.mako')

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def pay_accept(self, group):
        c.breadcrumbs.append(self._actions('home'))
        return render('group/pay_accept.mako')

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def pay_cancel(self, group):
        c.breadcrumbs.append(self._actions('home'))
        return render('group/pay_cancel.mako')

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def payment_deferred(self, group):
        return render('group/payment_deferred.mako')
