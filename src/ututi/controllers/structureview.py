import logging

from formencode import Schema, validators, compound, htmlfill
from webhelpers import paginate
from pylons.controllers.util import redirect, abort
from pylons import request
from pylons import tmpl_context as c, url
from pylons.i18n import _
from pylons.templating import render_mako_def

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.validators import LocationIdValidator, ShortTitleValidator, \
        FileUploadTypeValidator, validate
from ututi.lib.wall import WallMixin
from ututi.lib.search import search_query_count
from ututi.model import Subject, Group, Teacher
from ututi.model import LocationTag, meta
from ututi.model.users import User
from ututi.controllers.home import UniversityListMixin
from ututi.controllers.search import SearchSubmit, SearchBaseController

log = logging.getLogger(__name__)

def location_action(method):
    def _location_action(self, path, obj_type=None):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.security_context = location
        c.object_location = None
        c.location = location
        c.tabs = structure_menu_items()
        if obj_type is None:
            return method(self, location)
        else:
            return method(self, location, obj_type)
    return _location_action

def structure_menu_items():
    return [
        {'title': _("News feed"),
         'name': 'index',
         'link': c.location.url(action='index')},
        {'title': _("Subjects"),
         'name': 'subjects',
         'link': c.location.url(action='catalog', obj_type='subject')},
        {'title': _("Groups"),
         'name': 'groups',
         'link': c.location.url(action='catalog', obj_type='group')},
        {'title': _("Teachers"),
         'name': 'teachers',
         'link': c.location.url(action='catalog', obj_type='teacher')}]


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


class StructureviewWallMixin(WallMixin):

    def _wall_events_query(self):
        """WallMixin implementation."""
        from ututi.lib.wall import generic_events_query
        evts_generic = generic_events_query()

        t_evt = meta.metadata.tables['events']

        locations = [loc.id for loc in c.location.flatten]
        subjects = meta.Session.query(Subject)\
            .filter(Subject.location_id.in_(locations))\
            .all()
        public_groups = meta.Session.query(Group)\
            .filter(Group.location_id.in_(locations))\
            .filter(Group.forum_is_public == True)\
            .all()
        ids = [obj.id for obj in subjects + public_groups]

        return evts_generic\
            .where(t_evt.c.object_id.in_(ids))

class TeacherSearchMixin():

    def _search_teachers(self, location, text):
        locations = [loc.id for loc in location.flatten]

        query = meta.Session.query(Teacher)\
                .filter(Teacher.location_id.in_(locations))

        if text:
            query = query.filter(Teacher.fullname.contains(text))

        try:
            page_no = int(request.params.get('page', 1))
        except ValueError:
            abort(404)
        c.page = page_no

        c.results = paginate.Page(
            query,
            page=c.page,
            items_per_page = 30,
            item_count = search_query_count(query))
        c.searched = True


class StructureviewController(SearchBaseController, UniversityListMixin, StructureviewWallMixin, TeacherSearchMixin):

    def _breadcrumbs(self, location):
        c.breadcrumbs = []
        for tag in location.hierarchy(True):
            bc = {'link': tag.url(),
                  'title': tag.title_short}
            if tag.logo is not None:
                bc['logo'] = url(controller='structure', action='logo', width=30, height=30, id=tag.id)
            c.breadcrumbs.append(bc)

    @location_action
    def index(self, location):
        c.current_tab = 'index'

        self._breadcrumbs(location)
        self._set_wall_variables()

        if location.parent is None:
            self._get_departments(location)
        return render('location/feed.mako')

    def _edit_form(self):
        return render('location/edit.mako')

    @location_action
    @validate(schema=SearchSubmit, post_only=False, on_get=True)
    def catalog(self, location, obj_type):
        c.current_tab = obj_type + 's'
        self._breadcrumbs(location)

        self.form_result['tagsitem'] = location.hierarchy()
        self.form_result['obj_type'] = obj_type

        if obj_type == 'teacher':
            self._search_teachers(location, self.form_result.get('text', ''))
        else:
            self._search()

        if location.parent is None:
            self._get_departments(location)

        # render template by object type

        template_names = {'group': '/location/groups.mako',
                          'subject': '/location/subjects.mako',
                          'teacher': '/location/teachers.mako'}

        if obj_type in template_names:
            return render(template_names[obj_type])
        else:
            abort(404)

    @location_action
    @validate(schema=SearchSubmit, post_only=False, on_get=True)
    def catalog_js(self, location):
        self.form_result['tagsitem'] = location.hierarchy()
        if self.form_result.get('obj_type', None) is None:
            self.form_result['obj_type'] = '*'

        obj_type = self.form_result['obj_type']

        if obj_type == 'teacher':
            self._search_teachers(location, self.form_result.get('text', ''))
        else:
            self._search()


        if self.form_result.has_key('text'):
            search_query = self.form_result['text']
        else:
            search_query = None

        # return specific snippet per object type

        template_names = {'group': '/location/groups.mako',
                          'subject': '/location/subjects.mako',
                          'teacher': '/location/teachers.mako'}

        if obj_type in template_names:
            return render_mako_def(template_names[obj_type],
                                   'search_results',
                                   results=c.results,
                                   search_query=search_query)

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

    @location_action
    def login(self, location):
        email = request.POST.get('login')
        password = request.POST.get('password')
        remember = True if request.POST.get('remember', None) else False
        destination = c.came_from or location.url(action='index')

        if password is not None:
            user = User.authenticate(location, email, password.encode('utf-8'))
            c.header = _('Wrong username or password!')
            c.message = _('You seem to have entered your username and password wrong, please try again!')

            if user is not None:
                from ututi.lib.security import sign_in_user
                sign_in_user(user, long_session=remember)
                redirect(str(destination))

        return render('location/login.mako')
