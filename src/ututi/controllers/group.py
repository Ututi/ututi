import re
import logging
from datetime import date
from os.path import splitext

from pylons import c, config, request, url
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from formencode import Schema, validators, Invalid, variabledecode
from sqlalchemy.sql.expression import desc
from sqlalchemy.orm.exc import NoResultFound

import ututi.lib.helpers as h
from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render
from ututi.lib.validators import HtmlSanitizeValidator
from ututi.model.mailing import GroupMailingListMessage
from ututi.model import meta, Group, File, LocationTag
from routes import url_for

log = logging.getLogger(__name__)


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
            try:
                meta.Session.query(Group).filter_by(id=value).one()
                raise Invalid(self.message('duplicate', state), value, state)
            except NoResultFound:
                pass

            usernameRE = re.compile(r"^[^ \t\n\r@<>()]+$", re.I)
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
            if splitext(value.filename)[1] not in self.allowed_types:
                raise Invalid(self.message('bad_type', state, allowed=', '.join(self.allowed_types)), value, state)


class EditGroupForm(Schema):
    """A schema for validating group edits."""

    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True)
    description = validators.UnicodeString()
    year = validators.String()
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    logo_delete = validators.StringBoolean(if_missing=False)


class NewGroupForm(EditGroupForm):
    """A schema for validating new group forms."""

    pre_validators = [variabledecode.NestedVariables()]

    id = GroupIdValidator()


class GroupPageForm(Schema):
    allow_extra_fields = False
    page_content = HtmlSanitizeValidator()

def group_action(method):
    def _group_action(self, id):
        group = Group.get(id)
        if group is None:
            abort(404)
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group)
    return _group_action


class GroupControllerBase(BaseController):

    def __before__(self):
        c.breadcrumbs = [
            {'title': _('Groups'),
             'link': url_for(controller='group', action='index')}
            ]
        c.mailing_list_host = config.get('mailing_list_host', '')

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        return [
            {'title': _('Home'),
             'link': url(controller='group', action='group_home', id=c.group.id),
             'selected': selected == 'group_home'},
            {'title': _('Forum'),
             'link': url(controller='group', action='forum', id=c.group.id),
             'selected': selected == 'forum'},
            {'title': _('Members'),
             'link': url(controller='group', action='members', id=c.group.id),
             'selected': selected == 'members'},
            {'title': _('Files'),
             'link': url(controller='group', action='files', id=c.group.id),
             'selected': selected == 'files'},
            ]


class GroupController(GroupControllerBase):
    """Controller for group actions."""

    def index(self):
        c.groups = meta.Session.query(Group).all()
        return render('groups.mako')

    @group_action
    def group_home(self, group):
        c.group = group
        if request.GET.get('do', None) == 'hide_page':
            group.show_page = False
        meta.Session.commit()
        c.breadcrumbs.append(self._actions('group_home'))
        return render('group/home.mako')

    @group_action
    def edit_page(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('group_home'))
        return render('group/edit_page.mako')

    @group_action
    @validate(schema=GroupPageForm, form='edit_page')
    def update_page(self, group):
        page_content = self.form_result['page_content']
        if page_content is None:
            page_content = ''
        group.page = page_content
        meta.Session.commit()
        h.flash(_("The group's front page was updated."))
        redirect_to(controller='group', action='group_home', id=group.id)

    @group_action
    def files(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('files'))
        return render('group/files.mako')

    def add(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/add.mako')

    @validate(schema=NewGroupForm, form='add')
    def new_group(self):
        values = self.form_result

        group = Group(id=values['id'],
                      title=values['title'],
                      description=values['description'],
                      year=date(int(values['year']), 1, 1))

        location = values.get('schoolsearch', [])
        tag = LocationTag.get_by_title(location)
        group.location = tag

        meta.Session.add(group)

        if values['logo_upload'] is not None:
            logo = values['logo_upload']
            f = File(logo.filename, 'Logo for group %s' % group.title, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)
            group.logo = f

        meta.Session.commit()
        redirect_to(controller='group', action='group_home', id=values['id'])

    @group_action
    def members(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('members'))
        return render('group/members.mako')

    @group_action
    def edit(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('group_home'))

        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/edit.mako')

    @validate(EditGroupForm, form='edit')
    @group_action
    def update(self, group):
        values = self.form_result
        group.title = values['title']
        group.year = date(int(values['year']), 1, 1)
        group.description = values['description']

        if values['logo_delete']:
            meta.Session.delete(group.logo)
            group.logo = None

        if values['logo_upload'] is not None:
            logo = values['logo_upload']
            f = File(logo.filename, u'Logo for group %s' % group.title, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)

            if group.logo is not None:
                meta.Session.delete(group.logo)
            group.logo = f

        meta.Session.commit()
        redirect_to(controller='group', action='group_home', id=group.id)

    def logo(self, id, width=None, height=None):
        group = Group.get(id)
        return serve_image(group.logo, width=width, height=height)
