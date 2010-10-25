import logging

from formencode import Schema, validators, compound, htmlfill
from pylons.controllers.util import redirect, abort
from pylons import request
from pylons import tmpl_context as c, url
from pylons.i18n import _
from pylons.templating import render_mako_def

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.validators import LocationIdValidator, ShortTitleValidator, validate
from ututi.model import LocationTag, meta
from ututi.controllers.home import UniversityListMixin
from ututi.controllers.group import FileUploadTypeValidator
from ututi.controllers.search import SearchSubmit, SearchBaseController

log = logging.getLogger(__name__)

def location_action(method):
    def _location_action(self, path):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.security_context = location
        c.object_location = None
        c.location = location
        c.structure_menu_items = structure_menu_items()
        return method(self, location)
    return _location_action

def structure_menu_items():
    return [
        {'title': _("Groups"),
         'name': 'groups',
         'link': c.location.url(action='groups')},
        {'title': _("Subjects"),
         'name': 'subjects',
         'link': c.location.url(action='subjects')},
        {'title': _("Updates"),
         'name': 'index',
         'link': c.location.url(action='index')}]


class LocationEditForm(Schema):
    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True, strip=True)
    title_short = compound.All(validators.UnicodeString(not_empty=True, strip=True, max=50), ShortTitleValidator)
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    logo_delete = validators.StringBoolean(if_missing=False)
    site_url = validators.URL()
    chained_validators = [
        LocationIdValidator()
        ]


class StructureviewController(SearchBaseController, UniversityListMixin):

    def _breadcrumbs(self, location):
        c.breadcrumbs = []
        for tag in location.hierarchy(True):
            bc = {'link': tag.url(),
                  'title': tag.title_short}
            if tag.logo is not None:
                bc['logo'] = url(controller='structure', action='logo', width=30, height=30, id=tag.id)
            c.breadcrumbs.append(bc)

    @location_action
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def search_js(self, location):
        self.form_result['tagsitem'] = location.hierarchy()
        if self.form_result.get('obj_type', None) is None:
            self.form_result['obj_type'] = 'subject'
        self._search()

        return render_mako_def('/search/index.mako','search_results', results=c.results, controller='structureview', action='search_js')

    @location_action
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def index(self, location):
        c.structure_menu_current_item = 'index'
        self._breadcrumbs(location)

        self.form_result['tagsitem'] = location.hierarchy()
        if self.form_result.get('obj_type', None) is None:
            self.form_result['obj_type'] = 'subject'
        self._search()

        if location.parent is None:
            self._get_departments(location)
            if request.params.has_key('js'):
                return render_mako_def('/anonymous_index/en.mako', 'universities',
                                   unis=c.departments, ajax_url=location.url(), collapse=False, collapse_text=_('More departments'))

            return render('location/university.mako')
        else:
            return render('location/department.mako')

    def _edit_form(self):
        return render('location/edit.mako')

    @location_action
    def edit(self, location):
        defaults = {
            'old_path': '/'.join(location.path),
            'title': location.title,
            'title_short': location.title_short,
            'site_url': location.site_url
            }
        self._breadcrumbs(location)
        return htmlfill.render(self._edit_form(), defaults=defaults, force_defaults=False)

    @location_action
    @validate(schema=LocationEditForm, form='_edit_form')
    def update(self, location):
        self._breadcrumbs(location)

        if hasattr(self, 'form_result'):
            location.title = self.form_result['title']
            location.site_url = self.form_result['site_url']
            location.title_short = self.form_result['title_short']
            if self.form_result['logo_delete']:
                location.logo = None

            if self.form_result['logo_upload'] is not None and self.form_result['logo_upload'] != '':
                logo = self.form_result['logo_upload']
                location.logo = logo.file.read()

            meta.Session.commit()
            h.flash(_("Information updated."))
        redirect(url(controller='structureview', action='index', path='/'.join(location.path)))
