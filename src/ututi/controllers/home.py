import logging
from random import Random
import string
from datetime import date, timedelta

from formencode import Schema, validators, All, htmlfill
from formencode.compound import Pipe
from webhelpers import paginate

from babel.dates import format_date
from babel.dates import parse_date

from paste.util.converters import asbool
from pylons import request, tmpl_context as c, url, session, config, response
from pylons.controllers.util import abort, redirect
from pylons.i18n import _
from pylons.templating import render_mako_def

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import func
from sqlalchemy.sql.expression import desc

from ututi.lib.messaging import EmailMessage
from ututi.lib.base import BaseController, render, u_cache
import ututi.lib.helpers as h
from ututi.lib.emails import email_password_reset
from ututi.lib.security import sign_out_user
from ututi.lib.security import ActionProtector, sign_in_user, bot_protect
from ututi.lib.validators import (validate, u_error_formatters,
                                  TranslatedEmailValidator, ForbidPublicEmail)
from ututi.model import (meta, User, Region, LocationTag, Payment,
                         UserRegistration, EmailDomain)
from ututi.model import Subject, Group, SearchItem
from ututi.model.events import Event

log = logging.getLogger(__name__)

class PasswordRecoveryForm(Schema):
    allow_extra_fields = False
    email = All(
         TranslatedEmailValidator(not_empty=True)
         )


class PasswordResetForm(Schema):
    allow_extra_fields = True

    msg = {'empty': _(u"Please enter your password to register."),
           'tooShort': _(u"The password must be at least 5 symbols long.")}
    new_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)
    repeat_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)
    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password to register.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


class RegistrationForm(Schema):
    msg = {'public': _(u'Please use your university email or '
                        '<a href="/browse">choose university '
                        'from the list</a>.')}
    # url(controller='search', action='browse') here above
    email = Pipe(TranslatedEmailValidator(not_empty=True, strip=True),
                 ForbidPublicEmail(messages=msg))


class ContactsForm(Schema):
    msg = {'invalid': _(u"Wrong email address."),
           'empty': _(u"Field can't be empty.")}
    name = validators.UnicodeString(not_empty=True, messages=msg)
    email = Pipe(TranslatedEmailValidator(not_empty=True, strip=True, messages=msg))
    message = validators.UnicodeString(not_empty=True, messages=msg)


class UniversityListMixin(BaseController):
    """ A mix-in for listing all the universities (first level location tags) in the system."""

    @u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
    def _universities(self, sort_popularity=True, limit=None, region_id=None):
        unis = meta.Session.query(LocationTag
                ).filter(LocationTag.parent == None
                ).order_by(LocationTag.title.asc())
        if region_id:
            unis = unis.filter_by(region_id=region_id)
        unis = unis.all()
        if sort_popularity:
            unis.sort(key=lambda obj: obj.rating, reverse=True)
        if limit is not None:
            unis = unis[:limit]

        return [uni.info_dict() for uni in unis]

    @u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
    def _departments(self, parent_id, sort_popularity=True, limit=None, region_id=None):
        depts = meta.Session.query(LocationTag
                ).filter(LocationTag.parent_id == parent_id
                ).order_by(LocationTag.title.asc())
        if region_id:
            depts = depts.filter_by(region_id=region_id)
        depts = depts.all()
        if sort_popularity:
            depts.sort(key=lambda obj: obj.rating, reverse=True)
        if limit is not None:
            depts = depts[:limit]

        return [dept.info_dict() for dept in depts]

    @u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
    def _subjects(self):
        subjects = meta.Session.query(Subject).join(SearchItem).order_by(SearchItem.rating.desc()).limit(10).all()
        return [subject.info_dict() for subject in subjects]

    @u_cache(expire=3600, query_args=True, invalidate_on_startup=True, cache_response=False)
    def _groups(self):
        groups = meta.Session.query(Group).order_by(Group.created_on.desc()).limit(10).all()
        return [group.info_dict() for group in groups]

    def _get_unis(self):
        """List universities.

        Paging and sorting are performed according to request parameters.
        """
        c.sort = request.params.get('sort', 'popular')
        region_id = request.params.get('region_id')
        unis = self._universities(sort_popularity=(c.sort == 'popular'),
                                  region_id=region_id)
        c.unis = paginate.Page(
            unis,
            page=int(request.params.get('page', 1)),
            items_per_page=16,
            item_count=len(unis),
            **{'sort': c.sort}
            )
        c.teaser = not (request.params.has_key('page')
                        or request.params.has_key('sort')
                        or request.params.has_key('region_id'))


    def _get_departments(self, location):
        c.sort = request.params.get('sort', 'popular')
        region_id = request.params.get('region_id')
        departments = self._departments(parent_id=location.id, sort_popularity=(c.sort == 'popular'),
                                        region_id=region_id)
        c.departments = paginate.Page(
            departments,
            page=int(request.params.get('page', 1)),
            items_per_page=16,
            item_count=len(departments),
            **{'sort': c.sort}
            )
        c.teaser = not (request.params.has_key('page')
                        or request.params.has_key('sort')
                        or request.params.has_key('region_id'))



class HomeController(UniversityListMixin):

    def fbchannel(self):
        return render('/fbchannel.mako')

    def _sign_up_form(self):
        return render('/frontpage.mako')

    def _contacts_form(self):
        return render('/about/contacts.mako')

    def index(self):
        if c.user is not None:
            redirect(url(controller='profile', action='home'))
        else:
            self._get_unis()
            (c.subjects, c.groups, c.universities) = (self._subjects(), self._groups(), self._universities(limit=10))

            if request.params.has_key('js'):
                return render_mako_def('/anonymous_index/lt.mako','universities', unis=c.unis, ajax_url=url(controller='home', action='index'))
            c.slideshow = request.params.has_key('slide')
            return htmlfill.render(self._sign_up_form())

    def about(self):
        return render('/about/features.mako')

    @validate(schema=ContactsForm(), form='_contacts_form')
    def contacts(self):
        """Contact us form with send message functionality."""
        if not hasattr(self, 'form_result'):
            return self._contacts_form()

        name = self.form_result['name']
        email = self.form_result['email']
        message = self.form_result['message']

        text = render('/emails/contact_us.mako',
                      extra_vars={'name': name,
                                  'email': email,
                                  'message': message})
        msg = EmailMessage(_('Message to Ututi.com team'), text, force=True)
        msg.send('info@ututi.com')

        return render('/about/contacts.mako',
                      extra_vars={'message': _('Message sent succesfully.')})

    def features (self):
        return render('/about/features.mako')

    def advertising(self):
        return render('/advertising.mako')

    @ActionProtector("marketingist")
    def statistics(self):
        c.locations = meta.Session.query(Region, func.count(User.id)).filter(LocationTag.region_id == Region.id).filter(User.location_id == LocationTag.id).group_by(Region).all()

        c.geo_locations = meta.Session.query(User.location_city, func.count(User.id)).group_by(User.location_city).order_by(desc(func.count(User.id))).all()

        # Getting last week date range
        locale = c.locale
        from_time_str = format_date(date.today() - timedelta(7),
                                    format="short",
                                    locale=locale)
        to_time_str = format_date(date.today() + timedelta(1),
                                    format="short",
                                    locale=locale)
        from_time = parse_date(from_time_str, locale=locale)
        to_time = parse_date(to_time_str, locale=locale)

        uploads_stmt = meta.Session.query(
            Event.author_id,
            func.count(Event.created).label('uploads_count'))\
            .filter(Event.event_type == 'file_uploaded')\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .group_by(Event.author_id).order_by(desc('uploads_count')).limit(10).subquery()
        c.active_users = meta.Session.query(User,
                                            uploads_stmt.c.uploads_count.label('uploads'))\
                                            .join((uploads_stmt, uploads_stmt.c.author_id == User.id)).all()

        return render('/statistics.mako')

    def terms(self):
        return render('/terms.mako')

    def robots(self):
        response.headers['Content-Type'] = 'text/plain'
        if asbool(config.get('testing', False)):
            return 'User-agent: *\nDisallow: /'
        else:
            robots = ['User-agent: *',
                      'Allow: /',
                      '',
                      'User-agent: Googlebot',
                      'Disallow: /passwords',
                      'Disallow: /news/hourly',
                      'Disallow: /news/weekly',
                      'Allow: /']
            return '\n'.join(robots)

    def _check_login_context(self):
        """Checks context and sets up message for the login screen."""
        # TODO: this should better be a separate action but there are
        # many places where we redirect to login
        filename = request.params.get('context', None)
        context_type = request.params.get('context_type', None)
        if filename is not None:
            c.header = _('You have to be logged in to download a file!')
            c.message = _('After logging in you will be redirected to the download page of the file <strong>%(filename)s</strong> and the download will start automatically.') % dict(filename=filename)
        elif context_type == 'group_join':
            c.header = _('You have to log in or register to join a group!')
            c.message = _('After logging in or registering, your request to join the group will be sent.')
        elif context_type == 'support':
            c.header = _('Please log in to donate')
            c.message = _('Please log in before you donate so that we can associate the money you donate with your account.')
        else:
            c.header = _('Permission denied!')
            c.message = _('Only registered users can perform this action. Please log in, or register an account on our system.')

    def _try_sign_in(self, username, password, location=None, remember=False):
        # user may have registered in several Ututi
        # networks using same username
        locations = [user.location for user in User.get_all(username)]
        if len(locations) == 0:
            return {'username': _('Incorrect username.')}

        if len(locations) > 1:
            # if there is more than one location,
            # we will want to show it in the form
            c.locations = [(loc.id, loc.title) for loc in locations]
            c.selected_location = location

        if location is None and len(locations) == 1:
            location = locations[0].id

        if location is None:
            # still none! that means that location is not
            # unique and user did not specify it.
            return {'location': _('Please select your network.')}

        user = User.authenticate(location, username, password)
        if user is None:
            return {'password': _('Incorrect password.')}

        sign_in_user(user, long_session=remember)
        destination = c.came_from or url(controller='profile', action='home')
        redirect(destination)

    def login(self):
        # here below email get parameter may be used for convenience
        # i.e. when redirecting from sign-up form
        username = request.POST.get('username') or request.GET.get('email')
        password = request.POST.get('password')
        location = request.POST.get('location')
        location = int(location) if location else None
        remember = bool(request.POST.get('remember'))
        errors = None

        if username and password:
            # form was posted
            if location is not None: location = int(location)
            errors = self._try_sign_in(username, password, location, remember)

        # try_sign_in redirects upon successful authentication,
        # otherwise we show the form, possibly with errors.
        return htmlfill.render(render('login.mako'),
                               errors=errors,
                               error_formatters=u_error_formatters,
                               defaults={'username': username,
                                         'location': location,
                                         'came_from': c.came_from})

    def logout(self):
        sign_out_user()
        redirect(url(controller='home', action='index'))

    def _pswrecovery_form(self):
        return render('home/recoveryform.mako')

    @validate(PasswordRecoveryForm, form='_pswrecovery_form')
    def pswrecovery(self):
        if hasattr(self, 'form_result'):
            email = self.form_result.get('email', None)
            # TODO: this needs to be resolved, get_global is wrong here:
            user = User.get_global(email)
            if user is not None:
                if not user.recovery_key:
                    user.recovery_key = ''.join(Random().sample(string.ascii_lowercase, 8))
                email_password_reset(user, email)
                meta.Session.commit()
                h.flash(_('Password recovery email sent. Please check your inbox.'))
            else:
                h.flash(_('User account not found.'))

        return htmlfill.render(self._pswrecovery_form())

    def _pswreset_form(self):
        return render('home/password_resetform.mako')

    @validate(PasswordResetForm, form='_pswreset_form')
    def recovery(self, key=None):
        try:
            if hasattr(self, 'form_result'):
                key = self.form_result.get('recovery_key', '')
                defaults = {'recovery_key': key}
                user = meta.Session.query(User).filter(User.recovery_key == key).one()
                user.update_password(self.form_result.get('new_password'))
                user.recovery_key = None
                #password reset is actually a confirmation of the email
                user.emails[0].confirmed = True
                meta.Session.commit()
                h.flash(_('Your password has been updated. Welcome back!'))
                sign_in_user(user)
                redirect(url(controller='profile', action='index'))
            else:
                defaults={'recovery_key': key}
            c.key = key
            return htmlfill.render(self._pswreset_form(), defaults=defaults)
        except NoResultFound:
            abort(404)

    @bot_protect
    def process_transaction(self):
        prefix = 'wp_'
        args = ['projectid',
                'orderid',
                'lang',
                'amount',
                'currency',
                'paytext',
                '_ss2',
                '_ss1',
                'name',
                'surename',
                'status',
                'error',
                'test',
                'p_email',
                'payamount',
                'paycurrency',
                'version']

        kwargs = {}
        for arg in args:
            value = request.params.get(prefix + arg, '')
            kwargs[arg] = value

        payment = Payment(**kwargs)
        payment.referrer = request.referrer
        payment.query_string = request.query_string
        meta.Session.add(payment)
        meta.Session.commit()
        payment.process()
        meta.Session.commit()

        if payment.valid:
            return 'OK'
        else:
            return 'Error accepting payment'

    def tour(self):
        return render('tour.mako')

    def switch_language(self):
        language = request.params.get('language', 'en')
        # TODO validate
        # TODO store on user if user is logged in
        session['language'] = language
        session.save()
        redirect(c.came_from or url('/'))

    def register(self):
        email = request.POST.get('email')
        if not email:
            redirect(url('frontpage'))

        # redirect to login if user is already registered
        if User.get_all(email):
            redirect(url(controller='home', action='login', email=email))

        # otherwise we validate the form properly
        try:
            self.form_result = RegistrationForm().to_python(request.POST)
        except validators.Invalid, e:
            return htmlfill.render(self._sign_up_form(),
                                   defaults=request.POST,
                                   errors=e.error_dict,
                                   error_formatters=u_error_formatters)

        email = self.form_result['email']

        # lookup or create registration entry
        registration = UserRegistration.get_by_email(email)
        if registration is None:
            registration = UserRegistration(email=email)
            meta.Session.add(registration)

        # try to select location by domain name
        if registration.location is None:
            _, _, domain_name = email.rpartition('@')
            domain = EmailDomain.get_by_name(domain_name)
            if domain is not None:
                registration.location = domain.location

        meta.Session.commit()

        # send confirmation code to user
        registration.send_confirmation_email()

        # show confirmation page
        c.email = email
        return render('registration/email_approval.mako')

