import logging

from formencode import Schema, validators, compound, htmlfill

from webhelpers import paginate
from pylons.decorators import jsonify
from pylons.controllers.util import redirect, abort
from pylons import request
from pylons import tmpl_context as c, url
from pylons.i18n import _
from pylons.templating import render_mako_def

import ututi.lib.helpers as h
from ututi.lib.emails import teacher_confirmed_email
from ututi.lib.base import render
from ututi.lib.validators import LocationIdValidator, InURLValidator, \
        validate, TranslatedEmailValidator, \
        UniversityPolicyEmailValidator, UniqueLocationEmail, \
        MemberPolicyValidator, EmailDomainValidator, AvailableEmailDomain, \
        LogoUpload, CountryValidator, ColorHexCode
from ututi.lib.wall import WallMixin
from ututi.lib.search import search_query_count
from ututi.lib.emails import teacher_request_email
from ututi.lib.security import ActionProtector
from ututi.model import Subject, Group, Teacher
from ututi.model import LocationTag, EmailDomain, meta
from ututi.model.users import User, UserRegistration
from ututi.model.theming import Theme
from ututi.controllers.home import UniversityListMixin, switch_language
from ututi.controllers.search import SearchSubmit, SearchBaseController

log = logging.getLogger(__name__)

def location_menu_items():
    return [
        {'title': _("News feed"),
         'name': 'feed',
         'link': c.location.url(action='feed')},
        {'title': _("Subjects"),
         'name': 'subjects',
         'link': c.location.url(action='catalog', obj_type='subject')},
        {'title': _("Groups"),
         'name': 'groups',
         'link': c.location.url(action='catalog', obj_type='group')},
        {'title': _("Teachers"),
         'name': 'teachers',
         'link': c.location.url(action='catalog', obj_type='teacher')}]

def location_menu_public_items():
    return [
        {'title': _("About"),
         'name': 'about',
         'link': c.location.url(action='about')},
        {'title': _("Subjects"),
         'name': 'subjects',
         'link': c.location.url(action='catalog', obj_type='subject')},
        {'title': _("Teachers"),
         'name': 'teachers',
         'link': c.location.url(action='catalog', obj_type='teacher')}]

def location_edit_menu_items():
    return [
        {'title': _("General information"),
         'name': 'settings',
         'link': c.location.url(action='edit')},
        {'title': _("Registration settings"),
         'name': 'registration',
         'link': c.location.url(action='edit_registration')},
        {'title': _("Custom theme"),
         'name': 'theming',
         'link': c.location.url(action='edit_theme')},
        {'title': _("Unverified teachers"),
         'name': 'unverified_teachers',
         'link': c.location.url(action='unverified_teachers')},
    ]

def location_breadcrumbs(location):
    breadcrumbs = []
    for tag in location.hierarchy(True):
        bc = {'link': tag.url(),
              'full_title': tag.title,
              'title': tag.title_short}
        if tag.logo is not None:
            bc['logo'] = url(controller='structure', action='logo', width=30, height=30, id=tag.id)
        breadcrumbs.append(bc)
    return breadcrumbs

def location_action(method):
    def _location_action(self, path, obj_type=None):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.security_context = location
        c.object_location = None
        c.location = location
        c.breadcrumbs = location_breadcrumbs(location)
        c.theme = location.get_theme()

        if c.user:
            c.menu_items = location_menu_items()
        else:
            c.menu_items = location_menu_public_items()

        c.current_menu_item = None
        if obj_type is None:
            return method(self, location)
        else:
            return method(self, location, obj_type)
    return _location_action


class LocationEditForm(Schema):
    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True, strip=True)
    title_short = compound.All(validators.UnicodeString(not_empty=True, strip=True, max=50), InURLValidator)
    country = CountryValidator(not_empty=True)
    site_url = validators.URL()
    description = validators.UnicodeString(strip=True)
    chained_validators = [
        LocationIdValidator()
        ]


class ThemeForm(Schema):
    header_text = validators.String(strip=True, max=10)
    header_background_color = ColorHexCode()
    header_color = ColorHexCode()


class NewDomainForm(Schema):
    domain_name = compound.Pipe(validators.String(not_empty=True, strip=True),
                                EmailDomainValidator(),
                                AvailableEmailDomain())


class RegistrationSettingsForm(Schema):
    allow_extra_fields = True
    member_policy = MemberPolicyValidator()


class RegistrationForm(Schema):

    email = compound.Pipe(TranslatedEmailValidator(not_empty=True, strip=True),
                          UniqueLocationEmail(),
                          UniversityPolicyEmailValidator())


class TeacherRegistrationForm(Schema):

    email = compound.Pipe(TranslatedEmailValidator(not_empty=True, strip=True),
                          UniversityPolicyEmailValidator())


class LocationWallMixin(WallMixin):

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

        obj_id_in_list = t_evt.c.object_id.in_(ids) if ids else False
        return evts_generic\
            .where(obj_id_in_list)

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
            item_count = search_query_count(query),
            obj_type='teacher')
        c.searched = True


class LocationController(SearchBaseController, UniversityListMixin, LocationWallMixin, TeacherSearchMixin):

    @location_action
    def index(self, location):
        if c.user:
            redirect(location.url(action='feed'))
        else:
            redirect(location.url(action='about'))

    @location_action
    def about(self, location):
        c.current_menu_item = 'about'
        self._get_departments(location)
        return render('location/about.mako')

    @location_action
    @ActionProtector("user")
    def feed(self, location):
        c.current_menu_item = 'feed'
        self._set_wall_variables()
        return render('location/feed.mako')

    @location_action
    @validate(schema=SearchSubmit, post_only=False, on_get=True)
    def catalog(self, location, obj_type):
        c.current_menu_item = obj_type + 's'
        self.form_result['tagsitem'] = location.hierarchy()
        self.form_result['obj_type'] = obj_type

        c.text = self.form_result.get('text', '')

        if obj_type == 'teacher':
            self._search_teachers(location, c.text)
        else:
            self._search()

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
        obj_type = self.form_result.setdefault('obj_type', '*')

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

    def _edit_form(self):
        c.menu_items = location_edit_menu_items()
        c.current_menu_item = 'settings'
        return render('location/edit.mako')

    @location_action
    @ActionProtector('moderator')
    def edit(self, location):
        defaults = {
            'title': location.title,
            'title_short': location.title_short,
            'site_url': location.site_url,
            'description': location.description,
        }
        if location.country:
            defaults['country'] = location.country.id
        defaults['old_path'] = '/'.join(location.path)
        return htmlfill.render(self._edit_form(), defaults=defaults, force_defaults=False)

    @location_action
    @ActionProtector('moderator')
    @validate(schema=LocationEditForm, form='_edit_form')
    def update(self, location):
        if hasattr(self, 'form_result'):
            location.title = self.form_result['title']
            location.title_short = self.form_result['title_short']
            location.site_url = self.form_result['site_url']
            location.country = self.form_result['country']
            location.description = self.form_result['description']
            meta.Session.commit()
            h.flash(_("Information updated."))
        redirect(location.url(action='edit'))

    def _edit_registration_form(self):
        c.menu_items = location_edit_menu_items()
        c.current_menu_item = 'registration'
        return render('location/edit_registration.mako')

    @location_action
    @ActionProtector('moderator')
    @validate(schema=RegistrationSettingsForm, form='_edit_registration_form')
    def edit_registration(self, location):
        if hasattr(self, 'form_result'):
            location.member_policy = self.form_result['member_policy']
            h.flash(_("Registration settings updated."))
            meta.Session.commit()

        defaults = {
            'member_policy': location.member_policy
        }
        return htmlfill.render(self._edit_registration_form(),
                               defaults=defaults,
                               force_defaults=False)

    @location_action
    @ActionProtector('moderator')
    def delete_domain(self, location):
        if 'domain_id' in request.POST:
            try:
                id = int(request.POST['domain_id'])
            except ValueError:
                abort(404)
            domain = EmailDomain.get(id)
            if domain is not None and domain.location == location:
                domain.delete()
                meta.Session.commit()
                h.flash("Email domain %(domain_name)s deleted." % {
                    'domain_name': domain.domain_name})
        redirect(location.url(action='edit_registration'))

    @location_action
    @ActionProtector('moderator')
    @validate(schema=NewDomainForm, form='_edit_registration_form', force_defaults=False)
    def add_domain(self, location):
        if hasattr(self, 'form_result'):
            domain_name = self.form_result['domain_name']
            meta.Session.add(EmailDomain(domain_name, location))
            meta.Session.commit()
        redirect(location.url(action='edit_registration'))

    @location_action
    @ActionProtector('moderator')
    @validate(LogoUpload, form='edit_photo')
    def update_logo(self, location):
        if hasattr(self, 'form_result'):
            logo = self.form_result['logo']
            if logo is not None:
                location.logo = logo.file.read()
                meta.Session.commit()
                if 'js' not in request.params:
                    h.flash(_("Logo successfully updated."))
            if 'js' in request.params:
                return 'OK'
        redirect(location.url(action='edit'))

    @location_action
    @ActionProtector('moderator')
    def remove_logo(self, location):
        location.logo = None
        meta.Session.commit()
        h.flash(_("Your logo was removed."))
        redirect(location.url(action='edit'))

    def _edit_theme_form(self):
        return render('location/edit_theme_enabled.mako')

    @location_action
    @ActionProtector('moderator')
    def edit_theme(self, location):
        c.menu_items = location_edit_menu_items()
        c.current_menu_item = 'theming'
        if location.theme is None:
            c.example_theme = Theme()
            c.example_theme.header_logo = location.logo
            c.example_theme.header_text = ' '.join(location.path).upper()
            return render('location/edit_theme_disabled.mako')
        else:
            return htmlfill.render(
                self._edit_theme_form(),
                defaults=location.theme.values())

    @location_action
    @ActionProtector('moderator')
    def enable_theme(self, location):
        if 'enable_theme' in request.POST and location.theme is None:
            # initialize new theme
            parent_theme = location.get_theme()
            if parent_theme is not None:
                location.theme = parent_theme.clone()
            else:
                location.theme = Theme()
                location.theme.header_logo = location.logo
                location.theme.header_text = ' '.join(location.path).upper()
            meta.Session.commit()
        redirect(location.url(action='edit_theme'))

    @location_action
    @ActionProtector('moderator')
    def disable_theme(self, location):
        if 'disable_theme' in request.POST and location.theme is not None:
            location.theme.delete()
            meta.Session.commit()
        redirect(location.url(action='edit_theme'))

    @location_action
    @ActionProtector('moderator')
    @validate(ThemeForm, form='_edit_theme_form')
    def update_theme(self, location):
        if hasattr(self, 'form_result') and location.theme is not None:
            location.theme.update(self.form_result)
            meta.Session.commit()
        redirect(location.url(action='edit_theme'))

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

    def _register_form(self):
        return render('location/register.mako')

    @location_action
    @validate(schema=RegistrationForm(), form='_register_form')
    def register(self, location):
        if not hasattr(self, 'form_result'):
            return htmlfill.render(self._register_form())

        email = self.form_result['email']

        # redirect to login if user is registered in this university
        if User.get(email, location.root):
            h.flash(_('The email you entered is registered in Ututi. '
                      'Please login to proceed.'))
            redirect(url(controller='home', action='login', email=email))

        # lookup/create registration entry and send confirmation code to user
        registration = UserRegistration.create_or_update(location, email)
        meta.Session.commit()
        registration.send_confirmation_email()

        # show confirmation page
        c.email = email
        return render('registration/email_approval.mako')

    def _register_teacher_form(self):
        return render('location/register_teacher.mako')

    @location_action
    @validate(schema=TeacherRegistrationForm(), form='_register_teacher_form')
    def register_teacher(self, location):
        # bounce existing users to different action
        if c.user is not None:
            redirect(location.url(action='register_teacher_existing'))

        if not hasattr(self, 'form_result'):
            return htmlfill.render(self._register_teacher_form())

        email = self.form_result['email']

        if User.get(email, location):
            h.flash(_('The email you entered is registered in Ututi. '
                      'Please login to proceed.'))
            destination = location.url(action='register_teacher_existing')
            redirect(url(controller='home', action='login', email=email,
                         came_from=destination))

        # lookup/create registration entry and send confirmation code to user
        registration = UserRegistration.create_or_update(location, email)
        registration.teacher = True
        meta.Session.commit()
        registration.send_confirmation_email()

        # show confirmation page
        c.email = email
        return render('registration/email_approval.mako')

    @location_action
    @ActionProtector("user")
    def register_teacher_existing(self, location):
        if c.user.is_teacher:
            h.flash(_('You already have a teacher account.'))
            redirect(url(controller='profile', action='home'))

        teacher_request_email(c.user)
        h.flash(_('Thank You! Your request to become a teacher has been received. We will notify You once we grant You the rights of a teacher.'))
        redirect(location.url())

    @location_action
    def switch_language(self, location):
        # This is a general language switcher, but is placed here to
        # have a separate route for use in external university pages.
        language = request.params.get('language', 'en')
        # TODO validate
        switch_language(language)
        redirect(c.came_from or location.url())

    @location_action
    @ActionProtector('moderator')
    def unverified_teachers(self, location):
        c.menu_items = location_edit_menu_items()
        c.current_menu_item = 'unverified_teachers'
        c.teachers = meta.Session.query(Teacher)\
            .filter(Teacher.location==location)\
            .filter(Teacher.teacher_verified == False).all()
        c.found_users = []
        return render('location/edit_teachers.mako')

    @location_action
    @ActionProtector('moderator')
    def teacher_status(self, location):
        command, id = request.urlvars['command'], request.urlvars['id']
        teacher = meta.Session.query(Teacher).filter(Teacher.id == id).filter(Teacher.teacher_verified==False).one()
        if command == 'confirm':
            teacher.confirm()
            meta.Session.commit()
            teacher_confirmed_email(teacher, True)
            h.flash('Teacher confirmed.')
        else:
            teacher.revert_to_user()
            teacher_confirmed_email(teacher, False)
            h.flash('Teacher rejected.')

        redirect(location.url(action="unverified_teachers"))

    @location_action
    @jsonify
    def teachers_json(self, location):
        teachers = meta.Session.query(Teacher)\
            .filter(Teacher.location==location)\
            .filter(Teacher.teacher_verified == True).all()
        return {'teachers': sorted([{'name': teacher.fullname,
                                     'profile': teacher.url(action='external_teacher_index', qualified=True),
                                     'registered': teacher.accepted_terms.strftime('%Y-%m-%d %H:%M:%S'),
                                     'email': teacher.username if teacher.email_is_public else ''}
                                    for teacher in teachers], key=lambda t: t['registered'])}
