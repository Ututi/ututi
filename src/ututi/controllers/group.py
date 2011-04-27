import re
import logging
from datetime import date
from cStringIO import StringIO
import zipfile

import facebook

from pylons import tmpl_context as c, config, request, url, response
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect, abort
from pylons.decorators import jsonify
from pylons.i18n import ungettext, _

from webhelpers import paginate

from formencode import Schema, validators, Invalid, variabledecode, htmlfill
from formencode.compound import Pipe
from formencode.foreach import ForEach

from formencode.variabledecode import NestedVariables

from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy.sql.expression import or_

import ututi.lib.helpers as h
from ututi.lib.fileview import FileViewMixin
from ututi.lib.image import serve_logo
from ututi.lib.invitations import make_email_invitations, make_facebook_invitations,\
        extract_emails
from ututi.lib.search import _exclude_subjects
from ututi.lib.sms import sms_cost
from ututi.lib.base import BaseController, render
from ututi.lib.validators import js_validate
from ututi.lib.validators import HtmlSanitizeValidator, LocationTagsValidator, TagsValidator, FileUploadTypeValidator, validate
from ututi.lib.wall import WallMixin

from ututi.model import ForumCategory
from ututi.model import LocationTag, User, GroupMember, GroupMembershipType, File, OutgoingGroupSMSMessage
from ututi.model import meta, Group, SimpleTag, Subject, PendingInvitation, PendingRequest

from ututi.controllers.profile.validators import FriendsInvitationJSForm

from ututi.controllers.subject import SubjectAddMixin
from ututi.controllers.subject import NewSubjectForm
from ututi.controllers.search import SearchSubmit
from ututi.lib.security import bot_protect
from ututi.lib.security import is_root, check_crowds, deny
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query, search_query_count
from ututi.lib.emails import send_group_invitation_for_user
from ututi.lib.emails import send_group_invitation_for_non_user
from ututi.lib.emails import group_request_email, group_confirmation_email

log = logging.getLogger(__name__)


def set_login_url(method):
    def _set_login_url(self):
        c.login_form_url = url('login', came_from=url.current())
        return method(self)
    return _set_login_url


def set_login_url_to_referrer(method):
    def _set_login_url(self, group):
        c.login_form_url = request.referrer
        return method(self, group)
    return _set_login_url


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

            usernameRE = re.compile(r"^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*$", re.I)
            if not usernameRE.search(value):
                raise Invalid(self.message('badId', state), value, state)


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

    default_tab = validators.OneOf(['home', 'members', 'files', 'subjects'])
    approve_new_members = validators.OneOf(['none', 'admin'])
    forum_visibility = validators.OneOf(['public', 'members'])
    mailinglist_moderated = validators.OneOf(['members', 'moderated'])
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())
    can_add_subjects = validators.Bool()
    file_storage = validators.Bool()


class NewGroupForm(GroupForm):
    """A schema for validating new group forms."""
    # Deprecated.

    pre_validators = [variabledecode.NestedVariables()]
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

    id = Pipe(validators.String(strip=True, min=4, max=20), GroupIdValidator())


class CreateGroupForm(Schema):
    """A schema for group creation forms."""

    allow_extra_fields = True

    pre_validators = [variabledecode.NestedVariables()]

    msg = {'empty': _(u"Please enter a title.")}
    title = validators.UnicodeString(not_empty=True, messages=msg)
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())
    msg = {'empty': _(u"Please enter a group identifier."),
           'tooShort': _(u"The group identifier must be at least 4 characters long.")}
    id = Pipe(validators.String(strip=True, min=4, max=20, messages=msg),
              GroupIdValidator())
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    description = validators.UnicodeString()
    year = validators.String()


class GroupAddingForm(Schema):
    allow_extra_fields = True


class GroupPageForm(Schema):
    allow_extra_fields = True
    page_content = HtmlSanitizeValidator()


class GroupInvitationActionForm(Schema):
    allow_extra_fields = True
    accept = validators.OneOf(['True', 'False'])
    came_from = validators.URL(require_tld=False, not_empty=False, if_missing='')


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
    message = validators.UnicodeString(not_empty=False, if_missing='')


class GroupInviteCancelForm(Schema):
    """A schema for validating group member invitations"""
    allow_extra_fields = True
    email = validators.UnicodeString(not_empty=False)


def group_action(method):
    def _group_action(self, id=None):
        if id is None:
            redirect(url(controller='search', action='index', obj_type='group'))
        group = Group.get(id)
        if group is None:
            abort(404)
        c.security_context = group
        c.object_location = group.location
        c.group = group
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        c.group_menu_items = group_menu_items()
        c.group_id = c.group.group_id
        c.controller = self.controller_name
        return method(self, group)
    return _group_action


class GroupWallMixin(WallMixin):

    def _wall_events_query(self):
        """WallMixin implementation."""
        user_is_admin_of_groups = [membership.group_id
                                   for membership in c.user.memberships
                                   if membership.membership_type == 'administrator']
        from ututi.lib.wall import generic_events_query
        evts_generic = generic_events_query()
        t_evt = meta.metadata.tables['events']
        query = evts_generic\
                .where(or_(t_evt.c.object_id.in_([s.id for s in c.group.watched_subjects]),
                           t_evt.c.object_id == c.group.id))\
                .where(or_(t_evt.c.event_type != 'moderated_post_created',
                            t_evt.c.object_id.in_(user_is_admin_of_groups)))

        return query


def group_menu_items():
    """Generate a list of all possible actions."""
    files_entry = {
         'name': 'files',
         'title': _('Files'),
         'link': url(controller='group', action='files', id=c.group.group_id),
         'event': h.trackEvent(c.group, 'files', 'breadcrumb')
        } if c.group.has_file_area else None

    subjects_entry = {
         'name': 'subjects',
         'title': _('Subjects'),
         'link': url(controller='group', action='subjects', id=c.group.group_id),
         'event': h.trackEvent(c.group, 'subjects', 'breadcrumb')
        } if c.group.wants_to_watch_subjects else None

    bcs = [
        {'title': _("News feed"),
         'name': 'home',
         'link': url(controller='group', action='home', id=c.group.group_id),
         'event': h.trackEvent(c.group, 'home', 'breadcrumb')},
        ] + ([files_entry] if files_entry else []) + [
        ] + ([subjects_entry] if subjects_entry else []) + [
        {'title': _('Members'),
         'name': 'members',
         'link': url(controller='group', action='members', id=c.group.group_id),
         'event': h.trackEvent(c.group, 'members', 'breadcrumb')},
        {'title': _('Notes'),
         'name': 'page',
         'link': url(controller='group', action='page', id=c.group.group_id),
         'event': h.trackEvent(c.group, 'page', 'breadcrumb')},
        ]
    return bcs

class GroupController(BaseController, SubjectAddMixin, FileViewMixin, GroupWallMixin):
    """Controller for group actions."""

    controller_name = 'forum'

    @group_action
    def index(self, group):
        if check_crowds(["member", "admin"]):
            redirect(url(controller='group', action=c.group.default_tab, id=group.group_id))
        else:
            redirect(url(controller='group', action='home', id=group.group_id))

    def _set_home_variables(self, group):
        c.group_menu_current_item = 'home'
        c.has_to_invite_members = (len(group.members) == 1 and
                                   len(group.invitations) == 0)
        c.wants_to_watch_subjects = (len(group.watched_subjects) == 0 and
                                     group.wants_to_watch_subjects)
        c.show_info = True

        # wall's action block variables
        self._set_wall_variables()

    @group_action
    def home(self, group):
        if not c.user:
            abort(404);
        if check_crowds(["member", "admin"]):
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
    @ActionProtector("admin", "member")
    def welcome(self, group):
        self._set_home_variables(group)
        c.welcome = True
        return render('group/home.mako')

    @group_action
    def request_join(self, group):
        if c.user is None:
            c.login_form_url = url(controller='home',
                                   action='login',
                                   came_from=group.url(action='request_join'),
                                   context_type='group_join')
            deny(_('You have to log in or register to request group membership.'), 401)

        pending_request = PendingRequest.get(c.user, group)
        if pending_request is None and not group.is_member(c.user):
            if (self._check_handshakes(group, c.user) == 'invitation'
                or not group.admins_approve_members):
                group.add_member(c.user)
                if c.user.location is None:
                    c.user.location = group.location
                self._clear_requests(group, c.user)
                h.flash(_('You are now a member of the group %s!') % group.title)
            else:
                group.request_join(c.user)
                group_request_email(group, c.user)
                h.flash(_("Your request to join the group has been forwarded to the group's administrators. Thanks!"))
            meta.Session.commit()
        elif group.is_member(c.user):
            h.flash(_("You already are a member of this group."))
        else:
            h.flash(_("Your request to join the group is still being processed."))

        redirect(url(controller='group', action='home', id=group.group_id))

    def _edit_page_form(self):
        return render('group/edit_page.mako')

    @group_action
    @ActionProtector("admin", "member")
    def edit_page(self, group):
        c.group_menu_current_item = 'page'
        defaults = {
            'page_content': c.group.page,
            'page_public': 'public' if c.group.page_public else '',
            }
        return htmlfill.render(self._edit_page_form(), defaults=defaults)

    @group_action
    @validate(schema=GroupPageForm, form='_edit_page_form')
    @ActionProtector("admin", "member")
    def update_page(self, group):
        page_content = self.form_result['page_content']
        if page_content is None:
            page_content = u''
        group.page = page_content
        group.page_public = (self.form_result.get('page_public', False) == 'public')
        meta.Session.commit()
        h.flash(_("The group's front page was updated."))
        redirect(url(controller='group', action='page', id=group.group_id))

    @group_action
    @ActionProtector("member", "admin")
    def files(self, group):
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file

        c.group_menu_current_item = 'files'
        c.show_info = True

        return render('group/files.mako')

    def _create_form(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/create.mako')

    @set_login_url
    @validate(schema=CreateGroupForm, form='_create_form')
    @ActionProtector("user")
    def create(self):
        if hasattr(self, 'form_result'):
            values = self.form_result

            year = int(values.get('year') or date.today().year)
            group = Group(group_id=values['id'],
                          title=values['title'],
                          description=values['description'],
                          year=date(year, 1, 1))

            group.mailinglist_enabled = True
            group.location = values.get('location', None)

            meta.Session.add(group)

            if values['logo_upload'] is not None:
                logo = values['logo_upload']
                group.logo = logo.file.read()

            group.add_member(c.user, admin=True)
            meta.Session.commit()
            redirect(group.url(action='invite_members_step'))

        defaults = dict([('location-%d' % n, tag)
                         for n, tag in enumerate(c.user.location.hierarchy())])
        c.preset_location = c.user.location
        return htmlfill.render(self._create_form(), defaults=defaults)

    @group_action
    @ActionProtector("member", "admin")
    def members(self, group):
        c.group_menu_current_item = 'members'
        c.show_info = True
        self._set_up_member_info(group)
        if check_crowds(['admin', 'moderator'], context=group):
            return render('group/members_admin.mako')
        else:
            return render('group/members.mako')

    def _set_up_member_info(self, group):
        membertypes_users = meta.Session.query(GroupMember.membership_type, User
                                ).filter(GroupMember.user_id == User.id
                                ).filter(GroupMember.group_id == c.group.id
                                ).all()
        c.members = []
        single_admin = (c.group.n_administrators() == 1)
        for membership_type, user in membertypes_users:
            is_admin = membership_type == 'administrator'
            c.members.append({'roles': self._get_available_roles(is_admin, single_admin),
                              'user': user,
                              'title': user.fullname,
                              'last_seen': h.fmt_dt(user.last_seen),
                              })
        c.members.sort(key=lambda member: member['title'])

    def _get_available_roles(self, member_is_admin, single_administrator=False):
        roles = ({'type' : 'administrator', 'title' : _('Administrator')},
                 {'type' : 'member', 'title' : _('Member')},
                 {'type' : 'not-member', 'title': _('Delete member')})
        active_role = 'administrator' if member_is_admin else 'member'
        for role in roles:
            role['selected'] = role['type'] == active_role
        if member_is_admin and single_administrator:
            # Do not allow the last admin to relinquish privileges.
            roles = [role for role in roles
                     if role['type'] == 'administrator']
        return roles

    def _edit_form(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        files_link = ('files', _('Files')) if c.group.has_file_area else None
        subjects_link = ('subjects', _('Subjects')) if c.group.has_file_area else None
        c.tabs = [('home', _("News feed")),
                  ('members', _('Members'))
                  ] + ([files_link] if files_link else []) + [
                  ] + ([subjects_link] if subjects_link else []) + [
                  ('page', _('Notes'))]

        return render('group/edit.mako')

    @group_action
    @ActionProtector("admin")
    def edit(self, group):
        defaults = {
            'title': group.title,
            'description': group.description,
            'tags': ', '.join([tag.title for tag in c.group.tags]),
            'year': group.year.year,
            'default_tab': group.default_tab,
            'can_add_subjects': group.wants_to_watch_subjects,
            'file_storage': group.has_file_area,
            'approve_new_members': 'admin' if group.admins_approve_members else 'none',
            'forum_visibility': 'public' if group.forum_is_public else 'members',
            'page_visibility': 'public' if group.page_public else 'members',
            'mailinglist_moderated': 'moderated' if group.mailinglist_moderated else 'members',
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

        c.group_menu_current_item = 'home'

        return htmlfill.render(self._edit_form(), defaults=defaults)

    @group_action
    @validate(EditGroupForm, form='_edit_form')
    @ActionProtector("admin")
    def update(self, group):
        values = self.form_result
        group.title = values['title']
        if values['year']:
            group.year = date(int(values['year']), 1, 1)
        group.description = values['description']
        group.default_tab = values['default_tab']
        group.admins_approve_members = (
                self.form_result['approve_new_members'] == 'admin')
        group.forum_is_public = (
                self.form_result['forum_visibility'] == 'public')
        group.mailinglist_moderated = (
                self.form_result['mailinglist_moderated'] == 'moderated')
        group.mailinglist_enabled = True

        if not group.mailinglist_enabled and not group.forum_categories:
            group.forum_categories.append(ForumCategory(_('General'), _('Discussions on anything and everything')))

        if not (group.is_watching_subjects() and \
                group.wants_to_watch_subjects):
            group.wants_to_watch_subjects = bool(self.form_result['can_add_subjects'])

        if not (group.is_storing_files() and \
                group.has_file_area):
            group.has_file_area = bool(self.form_result['file_storage'])

        # Fix default tab setting if needed.
        if group.default_tab == 'forum' or group.default_tab == 'mailinglist':
            group.default_tab = 'home'

        if values['logo_delete']:
            group.logo = None

        if values['logo_upload'] is not None:
            logo = values['logo_upload']
            group.logo = logo.file.read()

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', []) if len(tag.strip()) < 250 and tag.strip() != '']
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',') if len(tag.strip()) < 250 and tag.strip() != '']

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

        redirect(url(controller='group', action='home', id=group.group_id))

    def logo(self, id, width=None, height=None):
        return serve_logo('group', id, width=width, square=True,
                default_img_path="public/images/details/icon_group_large.png")

    @group_action
    @ActionProtector("member", "admin")
    def invite_fb(self, group):
        # Handle POST.
        invited = request.params.get('ids[]')
        if invited:
            ids = invited.split(',')
            for facebook_id in ids:
                group.create_pending_fb_invitation(int(facebook_id), c.user)
            make_facebook_invitations(ids, c.user, group.location.root)
            meta.Session.commit()
            h.flash(ungettext('Invited %(num)d friend.',
                              'Invited %(num)d friends.',
                              len(ids)) % dict(num=len(ids)))
            redirect(c.group.url(action='members'))

        # Render page.
        fb_user = facebook.get_user_from_cookie(request.cookies,
                         config['facebook.appid'], config['facebook.secret'])
        c.has_facebook = fb_user is not None
        if c.has_facebook:
            try:
                graph = facebook.GraphAPI(fb_user['access_token'])
                friends = graph.get_object("me/friends")
            except facebook.GraphAPIError:
                c.has_facebook = False
        if not c.has_facebook:
            # Ask to log on to facebook.
            return render('group/invite.mako')

        friend_ids = [f['id'] for f in friends['data']]
        friend_users = meta.Session.query(User).filter(
                            User.facebook_id.in_(friend_ids)).all()
        c.exclude_ids = ','.join(str(u.facebook_id) for u in friend_users
                                 if c.group.is_member(u))
        return render('group/invite.mako')

    @group_action
    @set_login_url_to_referrer
    @ActionProtector("member", "admin")
    def upload_file(self, group):
        return self._upload_file(group)

    @group_action
    @set_login_url_to_referrer
    @ActionProtector("member", "admin")
    def upload_file_short(self, group):
        return self._upload_file_short(group)

    @group_action
    @ActionProtector("member", "admin")
    def create_folder(self, group):
        self._create_folder(group)
        redirect(request.referrer)

    @group_action
    @ActionProtector("admin")
    def delete_folder(self, group):
        self._delete_folder(group)
        redirect(request.referrer)

    @group_action
    @ActionProtector("member", "admin")
    def js_create_folder(self, group):
        return self._create_folder(group)

    @group_action
    @ActionProtector("admin")
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
        subject = self._getSubject()
        if subject in group.watched_subjects:
            group.watched_subjects.remove(subject)
        meta.Session.commit()

    @group_action
    @ActionProtector("admin", "member")
    def watch_subject(self, group):
        self._watch_subject(group)
        redirect(request.referrer)

    @group_action
    @ActionProtector("admin", "member")
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
    @ActionProtector("admin", "member")
    def unwatch_subject(self, group):
        self._unwatch_subject(group)
        redirect(request.referrer)

    @group_action
    @ActionProtector("admin", "member")
    def js_unwatch_subject(self, group):
        self._unwatch_subject(group)
        return "OK"

    @group_action
    @ActionProtector("member", "admin")
    def add_subject_step(self, group):
        c.step = True
        return render('group/add_subject.mako')

    def _createSubject(self, group):
        if not hasattr(self, 'form_result'):
            redirect(group.url(action='add_subject_step'))

        subject = self._create_subject()
        meta.Session.flush()
        group.watched_subjects.append(subject)

        meta.Session.commit()

    @validate(schema=NewSubjectForm, form='add_subject_step')
    @group_action
    @ActionProtector("member", "admin")
    def create_subject_step(self, group):
        self._createSubject(group)
        redirect(group.url(action='subjects_step'))

    @group_action
    @ActionProtector("member", "admin")
    def add_subject(self, group):
        return render('group/add_subject.mako')

    @validate(schema=NewSubjectForm, form='add_subject')
    @group_action
    @ActionProtector("member", "admin")
    def create_subject(self, group):
        self._createSubject(group)
        redirect(group.url(action='subjects'))

    @validate(schema=SearchSubmit, form='subjects', post_only=False, on_get=True)
    @group_action
    @ActionProtector("member", "admin")
    def subjects_step(self, group):
        c.step = True
        c.search_target = url(controller='group', action='subjects_step', id=group.group_id)
        return self._subjects(group)

    @validate(schema=SearchSubmit, form='subjects', post_only=False, on_get=True)
    @group_action
    @ActionProtector("member", "admin")
    def subjects_watch(self, group):
        c.group_menu_current_item = 'subjects'
        c.list_open = request.GET.get('list', '') == 'open'
        return self._subjects(group)

    @group_action
    @ActionProtector("member", "admin")
    def subjects(self, group):
        c.show_info = True
        c.group_menu_current_item = 'subjects'
        return render('group/subjects_list.mako')

    def _subjects(self, group):
        """
        The basis for views displaying all the subjects the group is already watching and allowing
        members to choose new subjects for the group.
        """
        c.search_target = url(controller='group', action='subjects_watch', id=group.group_id)

        #retrieve search parameters
        c.text = self.form_result.get('text', '')

        if 'tagsitem' in self.form_result or 'tags' in self.form_result:
            c.tags = self.form_result.get('tagsitem', None)
            if c.tags is None:
                c.tags = self.form_result.get('tags', None).split(', ')
        else:
            c.tags = c.group.location.hierarchy() if c.group.location is not None else []
        c.tags = ', '.join(filter(bool, c.tags))

        sids = [s.id for s in group.watched_subjects]

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        search_params['obj_type'] = 'subject'

        query = search_query(extra=_exclude_subjects(sids), **search_params)
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

    @group_action
    @validate(schema=GroupInviteForm, form='members', post_only=False, on_get=True)
    @ActionProtector("member", "admin")
    def invite_members(self, group):
        """Invite new members to the group."""
        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '')
            valid, invalid = extract_emails(emails)
            self._send_group_invitations(group, valid)
            if invalid != []:
                h.flash(_("Invalid email addresses detected: %s") % ', '.join(invalid))

        if request.referrer:
            redirect(request.referrer)
        else:
            redirect(url(controller='group', action='home', id=group.group_id))

    @group_action
    @js_validate(schema=FriendsInvitationJSForm())
    @jsonify
    def invite_members_js(self, group):
        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '')
            valid, invalid = extract_emails(emails)
            message = self.form_result['message']
            self._send_group_invitations(group, valid, message)

        return {'success': True}

    @group_action
    @validate(schema=GroupInviteCancelForm, form='members')
    @ActionProtector("admin")
    def cancel_invitation(self, group):
        """Cancel and delete an invitation that was sent out to the user."""
        if hasattr(self, 'form_result'):
            email = self.form_result.get('email', '')
            invitation = meta.Session.query(PendingInvitation
                    ).filter_by(group=group, email=email, active=True
                    ).first()
            if invitation is not None:
                invitation.active = False
                meta.Session.commit()
                h.flash(_('Invitation cancelled'))
        redirect(group.url(action='members'))

    @validate(schema=GroupInviteForm, form='invite_members_step')
    @group_action
    @ActionProtector("member", "admin")
    def invite_members_step(self, group):
        if hasattr(self, 'form_result'):
            emails = self.form_result.get('emails', '')
            valid, invalid = extract_emails(emails)
            self._send_group_invitations(group, valid)
            if invalid != []:
                h.flash(_("Invalid email addresses detected: %s") % ', '.join(invalid))

            if self.form_result.get('final_submit') is not None:
                redirect(group.url(action='welcome'))
            else:
                redirect(group.url(action='invite_members_step'))

        return render('group/members_step.mako')

    def _clear_requests(self, group, user):
        """Delete any pending invitations or requests for the group with the given email."""
        request = meta.Session.query(PendingRequest).filter_by(group=group, user=user).first()
        if request is not None:
            meta.Session.delete(request)
        invitations = meta.Session.query(PendingInvitation
                ).filter_by(group=group, user=user, active=True
                ).all()
        for invitation in invitations:
            invitation.active = None

    def _send_group_invitations(self, group, emails, message=None):
        invites, invalid, already = make_email_invitations(emails, c.user, group.location.root)
        # invites are registration objects!

        for email in already:
            user = User.get(email, group.location.root)
            if self._check_handshakes(group, user) == 'request':
                # Automatically accept requests to become group member.
                group.add_member(user)
                self._clear_requests(group, c.user)
                h.flash(_('New member %s added.') % user.fullname)
            else:
                invitation = group.create_pending_invitation(email, c.user)
                send_group_invitation_for_user(invitation, email, message)

        for registration in invites:
            invitation = group.create_pending_invitation(registration.email, c.user)
            send_group_invitation_for_non_user(invitation, registration, message)

        if invites:
            h.flash(_("Users invited."))
        if invalid != []:
            h.flash(_("Invalid email addresses detected: %s") % ', '.join(invalid))
        meta.Session.commit()

    def _check_handshakes(self, group, user):
        """Check if the user already has a request to join the group or an invitation."""
        request = meta.Session.query(PendingRequest
                 ).filter_by(group=group, user=user).first()
        invitation = meta.Session.query(PendingInvitation
                 ).filter_by(group=group, user=user, active=True
                 ).first()
        return request is not None and 'request' or invitation is not None and 'invitation'

    @validate(schema=GroupInvitationActionForm, post_only=False, on_get=True)
    @group_action
    def invitation(self, group):
        """Act on the invitation of the current user to this group."""
        if hasattr(self, 'form_result'):
            invitations = meta.Session.query(PendingInvitation
                            ).filter_by(group=group, user=c.user, active=True
                            ).all()

            if invitations:
                if self.form_result.get('accept', '') == 'True':
                    group.add_member(c.user)
                    if c.user.location is None:
                        c.user.location = group.location
                    h.flash(_("Congratulations! You are now a member of the group '%s'") % group.title)
                else:
                    h.flash(_("Invitation to group '%s' rejected.") % group.title)
                self._clear_requests(group, c.user)
                meta.Session.commit()

            came_from = self.form_result.get('came_from', None)
            if came_from is None:
                redirect(url(controller='group', action='home', id=group.group_id))
            else:
                redirect(came_from.encode('utf-8'))
        else:
            redirect(url(controller='group', action='home', id=group.group_id))

    @validate(schema=GroupRequestActionForm)
    @group_action
    def request(self, group):
        came_from = None
        if hasattr(self, 'form_result'):
            try:
                request = meta.Session.query(PendingRequest).filter_by(hash=self.form_result.get('hash_code', '')).one()
                if (self.form_result.get('action', 'deny') == 'confirm'):
                    c.group.add_member(request.user)
                    if request.user.location is None:
                        request.user.location = c.group.location
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

            came_from = self.form_result.get('came_from', None)

        if came_from is None:
            redirect(url(controller='group', action='members', id=c.group.group_id))
        else:
            redirect(came_from.encode('utf-8'))

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
        redirect(url(controller="group", action="members", id=group.group_id))

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
            redirect(url(controller='group', action='delete'))

    @group_action
    @ActionProtector("admin")
    def delete(self, group):
        if len(group.members) > 1:
            h.flash(_("You can't delete a group while it has members!"))
            redirect(request.referrer)
        else:
            h.flash(_("Group '%(group_title)s' has been deleted!" % dict(group_title=group.title)))
            meta.Session.delete(group)
            meta.Session.commit()
            redirect(url(controller='profile', action='home'))

    @group_action
    @ActionProtector("member", "admin")
    def unsubscribe(self, group):
        group.set_subscription(c.user, False)
        if request.params.has_key('js'):
            return 'ok'
        redirect(request.referrer)

    @group_action
    @ActionProtector("member", "admin")
    def subscribe(self, group):
        group.set_subscription(c.user, True)
        if request.params.has_key('js'):
            return 'ok'
        redirect(request.referrer)

    @group_action
    def send_sms(self, group):
        text = request.params.get('sms_message')
        if not text.strip():
            h.flash(_('Why would you want to send an empty SMS message?'))
            redirect(request.params.get('current_url'))
        cost = sms_cost(text, n_recipients=len(c.group.recipients_sms(sender=c.user)))
        if cost == 0:
            h.flash(_('Nobody received your message... No other group members have confirmed their phone numbers yet. Please encourage them to do so!'))
            redirect(request.params.get('current_url'))
        if c.user.sms_messages_remaining < cost:
            h.flash(_('Not enough SMS credits: you need %d, but you have only %d.')
                    % (cost, c.user.sms_messages_remaining))
            redirect(request.params.get('current_url'))

        c.user.sms_messages_remaining -= cost
        msg = OutgoingGroupSMSMessage(sender=c.user, group=group,
                                      message_text=text)
        meta.Session.add(msg)
        msg.send()
        meta.Session.commit()
        if request.params.has_key('js'):
            return _('SMS reply sent')
        h.flash(_('SMS sent! (%d credits used up, %d remaining)') % (cost, c.user.sms_messages_remaining))
        redirect(request.params.get('current_url'))

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
            redirect(request.referrer)
        meta.Session.commit()
        redirect(group.url())

    @group_action
    @ActionProtector("member", "admin")
    def page(self, group):
        c.group_menu_current_item = 'page'
        c.show_info = True
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
        redirect(url(controller='profile', action='notifications'))

    @validate(schema=GroupLiveSearchForm)
    def js_group_search(self):
        """Group live search in group creation view."""
        if hasattr(self, 'form_result'):
            location = self.form_result.get('location', None)
            year = self.form_result['year']
            groups = meta.Session.query(Group)
            if location is not None:
                groups = groups.filter(Group.location_id.in_([loc.id for loc in location.flatten]))
            if year != '':
                groups = groups.filter(Group.year == date(int(year), 1, 1))
            return render_mako_def('group/create_base.mako', 'live_search', groups=groups.all())
        else:
            abort(404)

    @jsonify
    @group_action
    @ActionProtector("admin", "member")
    def file_info(self, group):
        """Information on the group's usage of the files area."""
        info = {
            'image' : render_mako_def('sections/files.mako', 'free_space_indicator', obj=group),
            'text' : render_mako_def('sections/files.mako', 'free_space_text', obj=group) }
        section_id = request.POST.get('section_id', None)
        if section_id is not None:
            info['section_id'] = section_id
        return info

    @jsonify
    @group_action
    @ActionProtector("admin", "member")
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
    @ActionProtector("member", "admin")
    def pay(self, group):
        c.group_menu_current_item = 'home'
        return render('group/pay.mako')

    @group_action
    @ActionProtector("member", "admin")
    def pay_accept(self, group):
        redirect(url(controller='group', action='files',
                     id=group.group_id, just_paid=True))

    @group_action
    @ActionProtector("member", "admin")
    def pay_cancel(self, group):
        c.group_menu_current_item = 'home'
        return render('group/pay_cancel.mako')

    @group_action
    @ActionProtector("member", "admin")
    def payment_deferred(self, group):
        return render('group/payment_deferred.mako')

    @bot_protect
    def js_check_id(self):
        group_id = request.params.get('id')

        exists = len(group_id) < 4 or len(group_id) > 20

        try:
            GroupIdValidator.to_python(group_id)
        except Invalid:
            exists = True

        return render_mako_def('group/create_base.mako', 'id_check_response', group_id=group_id, taken=exists)

    @group_action
    @ActionProtector("member", "admin")
    def get_all_files(self, group):
        result = StringIO()
        zf = zipfile.ZipFile(result, "a", zipfile.ZIP_DEFLATED, False)
        for file in group.files:
            if file.isNullFile():
                continue
            file_name = file.title
            if file.folder:
                file_name = '%s/%s' % (file_name, file.folder)
            zf.writestr(file_name, open(file.filepath()).read())
        zf.close()
        response.headers['Content-Length'] = len(result.getvalue())
        response.headers['Content-Disposition'] = 'attachment; filename="%s_files.zip"' % group.group_id
        response.headers['Content-Type'] = 'application/zip'
        result.seek(0)
        return result
