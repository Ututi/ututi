import re
import logging
from datetime import date
from os.path import splitext

from pkg_resources import resource_stream

from pylons import c, config, request, url
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from webhelpers import paginate

from formencode import Schema, validators, Invalid, variabledecode, htmlfill
from formencode.compound import Pipe
from formencode.foreach import ForEach

from formencode.variabledecode import NestedVariables

from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import not_
from sqlalchemy.orm.exc import NoResultFound

import ututi.lib.helpers as h
from ututi.lib.fileview import FileViewMixin
from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render
from ututi.lib.validators import HtmlSanitizeValidator, LocationTagsValidator

from ututi.model.events import Event
from ututi.model import LocationTag, User, GroupMember, GroupMembershipType
from ututi.model import meta, Group, SimpleTag, Subject, ContentItem, PendingInvitation, PendingRequest
from ututi.controllers.subject import SubjectAddMixin
from ututi.controllers.subject import NewSubjectForm
from ututi.controllers.search import SearchSubmit
from ututi.lib.security import check_crowds
from ututi.lib.security import is_root, check_crowds
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query

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


class EditGroupForm(Schema):
    """A schema for validating group edits."""
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


class NewGroupForm(EditGroupForm):
    """A schema for validating new group forms."""

    pre_validators = [variabledecode.NestedVariables()]
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

    id = Pipe(validators.String(strip=True, min=4, max=20), GroupIdValidator())


class GroupAddingForm(Schema):
    allow_extra_fields = True


class GroupPageForm(Schema):
    allow_extra_fields = False
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


def group_action(method):
    def _group_action(self, id):
        group = Group.get(id)
        if group is None:
            abort(404)
        c.security_context = group
        c.object_location = group.location
        c.group = group
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group)
    return _group_action


class GroupControllerBase(BaseController):

    def __before__(self):
        c.breadcrumbs = []

        c.mailing_list_host = config.get('mailing_list_host', '')

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        return [
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
            ]

class GroupController(GroupControllerBase, FileViewMixin, SubjectAddMixin):
    """Controller for group actions."""

    @group_action
    def home(self, group):
        if check_crowds(["member", "admin", "moderator"]):
            if request.GET.get('do', None) == 'hide_page':
                group.show_page = False
                h.flash(_("The group's page was hidden. You can show it again by editing the group's settings."))
            meta.Session.commit()
            c.breadcrumbs.append(self._actions('home'))
            c.events = group.group_events
            return render('group/home.mako')
        else:
            c.breadcrumbs = [{'title': group.title,
                              'link': url(controller='group', action='home', id=c.group.group_id)}]

            return render('group/home_public.mako')

    @group_action
    @ActionProtector("user")
    def request_join(self, group):
        request = PendingRequest.get(c.user, group)
        if request is None and not group.is_member(c.user):
            group.request_join(c.user)
            meta.Session.commit()
            h.flash(_("Your request to join the group was forwarded to the group's administrators. Thank You!"))
        elif group.is_member(c.user):
            h.flash(_("You already are a member of this group."))
        else:
            h.flash(_("Your request to join the group is still being processed."))

        redirect_to(controller='group', action='home', id=group.group_id)

    @group_action
    @ActionProtector("admin", "moderator", "member")
    def edit_page(self, group):
        c.breadcrumbs.append(self._actions('home'))
        return render('group/edit_page.mako')

    @group_action
    @validate(schema=GroupPageForm, form='edit_page')
    @ActionProtector("admin", "moderator", "member")
    def update_page(self, group):
        page_content = self.form_result['page_content']
        if page_content is None:
            page_content = ''
        group.page = page_content
        meta.Session.commit()
        h.flash(_("The group's front page was updated."))
        redirect_to(controller='group', action='home', id=group.group_id)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def files(self, group):
        c.breadcrumbs.append(self._actions('files'))
        return render('group/files.mako')

    def _add_form(self):
        current_year = date.today().year
        c.years = range(current_year - 10, current_year + 5)
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
            'year': int(self.form_result.get('year',  date.today().year))
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
            redirect_to(controller='group', action='subjects_step', id=values['id'])
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

    @group_action
    @ActionProtector("admin", "moderator")
    def edit(self, group):
        c.group.tags_list = ', '.join([tag.title for tag in c.group.tags])
        c.breadcrumbs.append(self._actions('home'))

        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/edit.mako')

    @validate(EditGroupForm, form='edit')
    @group_action
    @ActionProtector("admin", "moderator")
    def update(self, group):
        values = self.form_result
        group.title = values['title']
        group.year = date(int(values['year']), 1, 1)
        group.description = values['description']

        if values['logo_delete']:
            group.logo = None

        if values['logo_upload'] is not None:
            logo = values['logo_upload']
            group.logo = logo.file.read()

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', [])]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',')]

        group.tags = []
        for tag in tags:
            group.tags.append(SimpleTag.get(tag))

        if not group.moderators or is_root(c.user):
            tag = values.get('location', None)
            group.location = tag

        if is_root(c.user):
            group.moderators = values['moderators']

        group.show_page = bool(values.get('show_page', False))

        meta.Session.commit()
        redirect_to(controller='group', action='home', id=group.group_id)

    def logo(self, id, width=None, height=None):
        group = Group.get(id)
        if group.logo is not None:
            return serve_image(group.logo, width=width, height=height)
        else:
            stream = resource_stream("ututi", "public/images/details/icon_group.png").read()
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
                            subject=self._getSubject())

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

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def subjects_step(self, group):
        c.step = True
        c.search_target = url(controller = 'group', action='subjects_step', id = group.group_id)
        return self.subjects(group.group_id)

    @group_action
    @ActionProtector("member", "admin", "moderator")
    def add_subject_step(self, group):
        c.step = True
        return render('group/add_subject.mako')

    @validate(schema=NewSubjectForm, form='add_subject_step')
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def create_subject(self, group):
        if not hasattr(self, 'form_result'):
            redirect_to(group.url(action='add_subject_step'))

        subject = self._create_subject()
        meta.Session.flush()
        group.watched_subjects.append(subject)

        meta.Session.commit()
        redirect_to(group.url(action='subjects_step'))


    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def subjects(self, group):
        """
        A view displaying all the subjects the group is already watching and allowing
        members to choose new subjects for the group.
        """
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

        if search_params != {}:
            c.results = paginate.Page(
                query,
                page=int(request.params.get('page', 1)),
                item_count = query.count() or 0,
                items_per_page = 10,
                **search_params)


        c.breadcrumbs.append(self._actions('subjects'))
        if check_crowds(["admin", "moderator"]):
            return render('group/subjects.mako')
        else:
            return render('group/subjects_member.mako')

    @validate(schema=GroupInviteForm, form='members', post_only = False, on_get = True)
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def invite_members(self, group):
        """Invite new members to the group."""
        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '').split()
            self._send_invitations(group, emails)
        redirect_to(controller='group', action='members', id=group.group_id)

    @validate(schema=GroupInviteForm, form='invite_members_step')
    @group_action
    @ActionProtector("member", "admin", "moderator")
    def invite_members_step(self, group):

        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '').split()
            self._send_invitations(group, emails)
            if self.form_result.get('final_submit', None) is not None:
                redirect_to(controller='group', action='home', id=group.group_id)
            else:
                redirect_to(controller='group', action='invite_members_step', id=group.group_id)

        return render('group/members_step.mako')

    def _send_invitations(self, group, emails):
        count = 0
        failed = []
        for line in emails:
            for email in filter(bool, line.split(',')):
                #XXX : need to validate emails
                try:
                    validators.Email.to_python(email)
                    count = count + 1
                    group.invite_user(email, c.user)
                except:
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
                meta.Session.delete(invitation)
                if self.form_result.get('action', '') == 'accept':
                    group.add_member(c.user)
                    h.flash(_("Congratulations! You are now a member of the group '%s'") % group.title)
                else:
                    h.flash(_("Invitation to group '%s' rejected.") % group.title)
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
                    h.flash(_(u"New member %s added.") % request.user.fullname)
                else:
                    h.flash(_(u"Group membership denied to %s.") % request.user.fullname)
                meta.Session.delete(request)
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
                elif role in ['members', 'administrator']:
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
