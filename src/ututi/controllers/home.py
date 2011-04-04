import logging
from random import Random
import string
from datetime import datetime, date, timedelta

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

from ututi.lib.base import BaseController, render, u_cache
import ututi.lib.helpers as h
from ututi.lib.emails import email_password_reset
from ututi.lib.invitations import bind_group_invitations
from ututi.lib.security import sign_out_user
from ututi.lib.security import ActionProtector, sign_in_user, bot_protect
from ututi.lib.validators import (validate, TranslatedEmailValidator,
                                  ForbidPublicEmail)
from ututi.model import (meta, User, Region, Email, PendingInvitation,
                         LocationTag, Payment, UserRegistration, EmailDomain)
from ututi.model import Subject, Group, SearchItem
from ututi.model.events import Event
from ututi.controllers.federation import FederationMixin, FederatedRegistrationForm

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



class HomeController(UniversityListMixin, FederationMixin):

    def fbchannel(self):
        return render('/fbchannel.mako')

    def index(self):
        if c.user is not None:
            redirect(url(controller='profile', action='home'))
        else:
            self._get_unis()
            (c.subjects, c.groups, c.universities) = (self._subjects(), self._groups(), self._universities(limit=10))

            if request.params.has_key('js'):
                return render_mako_def('/anonymous_index/lt.mako','universities', unis=c.unis, ajax_url=url(controller='home', action='index'))
            c.slideshow = request.params.has_key('slide')
            return render('/anonymous_index.mako')

    def about(self):
        return render('/about.mako')

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

    def require_login(self):
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

        return render('/login.mako')

    def login(self):
        username = request.POST.get('username')
        password = request.POST.get('password')
        remember = request.POST.get('remember', False)
        destination = c.came_from or url(controller='profile', action='home')

        if password is not None:
            user = User.authenticate_global(username, password.encode('utf-8'))
            c.header = _('Wrong username or password!')
            c.message = _('You seem to have entered your username and password wrong, please try again!')

            if user is not None:
                sign_in_user(user, long_session=remember)
                redirect(str(destination))

        return render('/login.mako')

    def logout(self):
        sign_out_user()
        redirect(url(controller='home', action='index'))

    def _pswrecovery_form(self):
        return render('home/recoveryform.mako')

    def _federated_registration_form(self):
        c.email = session.get('confirmed_email', '').lower()
        return render('home/federated_registration.mako')

    @validate(FederatedRegistrationForm, form='_federated_registration_form')
    def federated_registration(self):
        if not (session.get('confirmed_openid') or session.get('confirmed_facebook_id')):
            redirect(url(controller='home', action='index'))
        c.email = session.get('confirmed_email').lower()
        if hasattr(self, 'form_result'):
            user = User.get(c.email, self.form_result['location'])
            if not user:
                # Make sure that such a user does not exist.
                user = User(fullname=self.form_result['fullname'],
                            username=c.email,
                            location=self.form_result['location'],
                            password=None,
                            gen_password=False)
                self._bind_user(user, flash=False)
                user.accepted_terms = datetime.utcnow()
                user.emails = [Email(c.email)]
                user.emails[0].confirmed = True
                user.phone_number = self.form_result['phone']
                bind_group_invitations(user)
                meta.Session.add(user)
                meta.Session.commit()
            sign_in_user(user)

            invitation_hash = self.form_result.get('invitation_hash', '')
            if invitation_hash:
                invitation = PendingInvitation.get(invitation_hash)
                if invitation is not None:
                    invitation.group.add_member(user)
                    meta.Session.delete(invitation)
                    meta.Session.commit()
                    redirect(url(controller='group', action='home',
                                 id=invitation.group.group_id))

            kwargs = dict()
            if user.facebook_id:
                kwargs['fb'] = True

            redirect(c.came_from or url(controller='profile',
                                        action='register_welcome', **kwargs))

        # Render form: suggested name, suggested email, agree with conditions
        defaults = dict(fullname=session.get('confirmed_fullname'),
                    email=c.email,
                    invitation_hash=request.params.get('invitation_hash', ''))
        return htmlfill.render(self._federated_registration_form(),
                               defaults=defaults)

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

    @validate(schema=RegistrationForm(), form='index')
    def register(self):
        if not hasattr(self, 'form_result'):
            redirect(url('frontpage'))

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

