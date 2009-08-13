import re
import logging
from datetime import date
from os.path import splitext

from pylons import c, config, request, url
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from webhelpers import paginate

from formencode import Schema, validators, Invalid, variabledecode
from formencode.compound import Pipe
from formencode.foreach import ForEach

from formencode.variabledecode import NestedVariables

from sqlalchemy.sql.expression import not_

import ututi.lib.helpers as h
from ututi.lib.fileview import FileViewMixin
from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render
from ututi.lib.validators import HtmlSanitizeValidator, LocationTagsValidator

from ututi.model import LocationTag
from ututi.model import meta, Group, File, SimpleTag, Subject, ContentItem
from ututi.controllers.search import SearchSubmit
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
    pre_validators = [NestedVariables()]

    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True)
    description = validators.UnicodeString()
    year = validators.String()
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    logo_delete = validators.StringBoolean(if_missing=False)
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())


class NewGroupForm(EditGroupForm):
    """A schema for validating new group forms."""

    pre_validators = [variabledecode.NestedVariables()]
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

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
             'link': url(controller='group', action='index')}
            ]
        c.mailing_list_host = config.get('mailing_list_host', '')

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        return [
            {'title': _('Home'),
             'link': url(controller='group', action='group_home', id=c.group.group_id),
             'selected': selected == 'group_home'},
            {'title': _('Forum'),
             'link': url(controller='group', action='forum', id=c.group.group_id),
             'selected': selected == 'forum'},
            {'title': _('Members'),
             'link': url(controller='group', action='members', id=c.group.group_id),
             'selected': selected == 'members'},
            {'title': _('Files'),
             'link': url(controller='group', action='files', id=c.group.group_id),
             'selected': selected == 'files'},
            {'title': _('Subjects'),
             'link': url(controller='group', action='subjects', id=c.group.group_id),
             'selected': selected == 'subjects'},
            ]


class GroupController(GroupControllerBase, FileViewMixin):
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
        redirect_to(controller='group', action='group_home', id=group.group_id)

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

        group = Group(group_id=values['id'],
                      title=values['title'],
                      description=values['description'],
                      year=date(int(values['year']), 1, 1))

        tag = values.get('location', None)
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
        c.group.tags_list = ', '.join([tag.title for tag in c.group.tags])
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

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', [])]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',')]

        group.tags = []
        for tag in tags:
            group.tags.append(SimpleTag.get(tag))


        meta.Session.commit()
        redirect_to(controller='group', action='group_home', id=group.group_id)

    def logo(self, id, width=None, height=None):
        group = Group.get(id)
        return serve_image(group.logo, width=width, height=height)

    @group_action
    def upload_file(self, group):
        return self._upload_file(group)

    @group_action
    def create_folder(self, group):
        return self._create_folder(group)

    @group_action
    def delete_folder(self, group):
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
    def watch_subject(self, group):
        self._watch_subject(group)
        redirect_to(request.referrer)

    @group_action
    def js_watch_subject(self, group):
        self._watch_subject(group)
        return "OK"

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    def unwatch_subject(self, group):
        self._unwatch_subject(group)
        redirect_to(request.referrer)

    @group_action
    def js_unwatch_subject(self, group):
        self._unwatch_subject(group)
        return "OK"

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @group_action
    def subjects(self, group):
        """
        A view displaying all the subjects the group is already watching and allowing
        members to choose new subjects for the group.
        """
        c.group = group

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

        if search_params != {}:
            c.results = paginate.Page(
                search_query(extra=_filter_watched_subjects(sids), **search_params),
                page=int(request.params.get('page', 1)),
                items_per_page = 10,
                **search_params)


        c.breadcrumbs.append(self._actions('subjects'))
        return render('group/subjects.mako')
