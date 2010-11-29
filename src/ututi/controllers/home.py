import logging
from random import Random
import string
from datetime import datetime, date, timedelta

from formencode import Schema, validators, Invalid, All, htmlfill
from webhelpers import paginate

from babel.dates import format_date
from babel.dates import parse_date

from paste.util.converters import asbool
from pylons import request, tmpl_context as c, url, session, config, response
from pylons.controllers.util import abort, redirect
from pylons.i18n import _, ungettext
from pylons.templating import render_mako_def

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import func
from sqlalchemy.sql.expression import desc

from ututi.lib.base import BaseController, render, render_lang, u_cache
import ututi.lib.helpers as h
from ututi.lib import gg
from ututi.lib.emails import email_confirmation_request, email_password_reset
from ututi.lib.messaging import EmailMessage
from ututi.lib.security import ActionProtector, sign_in_user
from ututi.lib.validators import validate, UniqueEmail, TranslatedEmailValidator
from ututi.model import meta, User, Region, Email, PendingInvitation, LocationTag, Payment, get_supporters
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

    allow_extra_fields = True

    msg = {'missing': _(u"You must agree to the terms of use.")}
    agree = validators.StringBool(messages=msg)

    msg = {'empty': _(u"Please enter your name to register.")}
    fullname = validators.String(not_empty=True, strip=True, messages=msg)

    msg = {'non_unique': _(u"This email has already been used to register.")}
    email = All(TranslatedEmailValidator(not_empty=True, strip=True),
                UniqueEmail(messages=msg, strip=True, completelyUnique=True))

    msg = {'empty': _(u"Please enter your password to register."),
           'tooShort': _(u"The password must be at least 5 symbols long.")}
    new_password = validators.String(
         min=5, not_empty=True, strip=True, messages=msg)
    repeat_password = validators.String(
         min=5, not_empty=True, strip=True, messages=msg)

    gadugadu = validators.Int()

    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password to register.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


class RecommendationForm(Schema):
    """A schema for validating ututi recommendation submissions"""
    allow_extra_fields = True
    recommend_emails = validators.UnicodeString(not_empty=False)
    came_from = validators.URL(require_tld=False)


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
    def _departments(self, parent, sort_popularity=True, limit=None, region_id=None):
        depts = meta.Session.query(LocationTag
                ).filter(LocationTag.parent == parent
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
        departments = self._departments(parent=location,sort_popularity=(c.sort == 'popular'),
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

    def __before__(self):
        c.ututi_supporters = get_supporters()

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
        return render_lang('/about.mako')

    def advertising(self):
        return render_lang('/advertising.mako')

    @ActionProtector("marketingist")
    def statistics(self):
        c.locations = meta.Session.query(Region, func.count(User.id)).filter(LocationTag.region_id == Region.id).filter(User.location_id == LocationTag.id).group_by(Region).all()

        c.geo_locations = meta.Session.query(User.location_city, func.count(User.id)).group_by(User.location_city).order_by(desc(func.count(User.id))).all()

        # Getting last week date range
        locale = config.get('locale')
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
        return render_lang('/terms.mako')

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

    def login(self):
        email = request.POST.get('login')
        password = request.POST.get('password')
        remember = True if request.POST.get('remember', None) else False
        destination = c.came_from or url(controller='profile', action='home')
        filename = request.params.get('context', None)

        context_type = request.params.get('context_type', None)
        c.show_warning = True

        if filename is not None:
            c.header = _('You have to be logged in to download a file!')
            c.message = _('After logging in you will be redirected to the download page of the file <strong>%(filename)s</strong> and the download will start automatically.') % dict(filename=filename)
            c.show_login = True
        elif context_type == 'group_join':
            c.header = _('You have to log in or register to join a group!')
            c.message = _('After logging in or registering, your request to join the group will be sent.')
            c.show_login = True
        elif context_type == 'support':
            c.header = _('Please log in to donate')
            c.message = _('Please log in before you donate so that we can associate the money you donate with your account.')
            c.show_login = True
        elif context_type == "books_login":
            c.show_warning = False
        elif context_type == "books_register":
            c.show_login = True
            c.show_warning = False
        else:
            c.header = _('Permission denied!')
            c.message = _('Only registered users can perform this action. Please log in, or register an account on our system.')
            c.show_login = True
        c.final_msg = _('If this is your first time visiting <a href="%(url)s">Ututi</a>, please register first.') % dict(url=url('/', qualified=True))

        if password is not None:
            user = User.authenticate(email, password.encode('utf-8'))
            c.header = _('Wrong username or password!')
            c.message = _('You seem to have entered your username and password wrong, please try again!')

            if user is not None:
                sign_in_user(user, long_session=remember)
                redirect(str(destination))

        return render('/login.mako')

    def logout(self):
        if 'login' in session:
            del session['login']
        response.delete_cookie('ututi_session_lifetime')
        session.save()
        redirect(url(controller='home', action='index'))

    def __register_user(self, form, send_confirmation=True):
        fullname = self.form_result['fullname']
        password = self.form_result['new_password']
        email = self.form_result['email'].lower()

        user = User.get(email)
        if user:
            # A user with this email exists, just sign them in.
            sign_in_user(user)
            return (user, email)

        gadugadu_uin = self.form_result['gadugadu']

        user = User(fullname, password)
        user.emails = [Email(email)]
        user.accepted_terms = datetime.utcnow()
        #all newly registered users are marked when they agree to the terms of use

        meta.Session.add(user)
        meta.Session.commit()
        if send_confirmation:
            email_confirmation_request(user, email)
        else:
            user.emails[0].confirmed = True
            meta.Session.commit()

        if gadugadu_uin:
            user.gadugadu_uin = gadugadu_uin
            gg.confirmation_request(user)
            meta.Session.commit()

        sign_in_user(user)
        return (user, email)

    @validate(schema=RegistrationForm(), form='register')
    def register(self, hash=None):
        c.hash = hash
        c.show_login = False
        c.show_registration = True
        if hasattr(self, 'form_result'):
            # Form validation was successful.
            if hash is not None:
                invitation = PendingInvitation.get(hash)
                if invitation is not None and invitation.email.lower() == self.form_result['email'].lower():
                    user, email = self.__register_user(self.form_result, False)
                    invitation.group.add_member(user)
                    meta.Session.delete(invitation)
                    meta.Session.commit()
                    redirect(url(controller='group', action='home', id=invitation.group.group_id))
                elif invitation is None:
                    c.header = _('Invalid invitation!')
                    c.message = _('The invitation link you have followed was either already used or invalid.')
                    return render('/login.mako')
                else:
                    c.email = invitation.email
                    c.header = _('Invalid email!')
                    c.message = _('You can only use the email this invitation was sent for to register.')
                    return render('/login.mako')
            else:
                user, email = self.__register_user(self.form_result)
                redirect(str(request.POST.get('came_from',
                                                 url(controller='profile',
                                                     action='register_welcome'))))
        else:
            # Form validation failed.
            if hash is not None:
                invitation = PendingInvitation.get(hash)
                if invitation is not None:
                    c.email = invitation.email
                    c.message_class = 'please-register'
                    c.header = _('Please register!')
                    c.message = _('Only registered users can become members of a group, please register first.')
                else:
                    c.header = _('Invalid invitation!')
                    c.message = _('The invitation link you have followed was either already used or invalid.')
                return render('/login.mako')

            self._get_unis()
            (c.subjects, c.groups, c.universities) = (self._subjects(), self._groups(), self._universities(limit=10))
            return render('/login.mako')

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
            user = User.get(c.email)
            if not user:
                # Make sure that such a user does not exist.
                user = User(self.form_result['fullname'], None, gen_password=False)
                self._bind_user(user, flash=False)
                if user.facebook_id:
                    self._bind_facebook_invitations(user)
                user.accepted_terms = datetime.utcnow()
                user.emails = [Email(c.email)]
                user.emails[0].confirmed = True

                user.location = self.form_result['location']
                user.phone_number = self.form_result['phone']
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
            user = User.get(email)
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

            return htmlfill.render(self._pswreset_form(), defaults=defaults)
        except NoResultFound:
            abort(404)

    @validate(schema=RecommendationForm)
    @ActionProtector("user")
    def send_recommendations(self):
        if hasattr(self, 'form_result'):
            count = 0
            failed = []
            rcpt = []
            using = [] #already members of ututi

            #constructing the message
            extra_vars = {'user_name': c.user.fullname}
            text = render('/emails/recommendation_text.mako',
                          extra_vars=extra_vars)
            html = render('/emails/recommendation_html.mako',
                          extra_vars=extra_vars)
            msg = EmailMessage(_('%(fullname)s wants you to join Ututi') % dict(fullname = c.user.fullname), text, html)

            emails = self.form_result.get('recommend_emails', '').split()
            for line in emails:
                for email in filter(bool, line.split(',')):
                    try:
                        TranslatedEmailValidator.to_python(email)
                        exists = meta.Session.query(Email).filter(Email.email == email).first()
                        if exists is None:
                            count = count + 1
                            rcpt.append(email)
                        else:
                            using.append(email)
                    except Invalid:
                        failed.append(email)
            if rcpt != []:
                msg.send(rcpt)

            status = {}
            if count > 0:
                status['ok'] = ungettext('%(count)d invitation sent.',
                                         '%(count)d invitations sent.', count) % {'count': count}

            if len(using) > 0:
                status['members'] = _('Already using ututi: %s.') % ', '.join(using)

            if len(failed) > 0:
                status['fail'] = _('Invalid emails: %s') % ', '.join(failed)

            if request.params.has_key('js'):
                for k in status:
                    status[k] = '<div class="%(cls)s">%(val)s</div>' % dict(cls=k, val=status[k])
                return ''.join([v for v in status.values()])
            else:
                for v in status.values():
                    h.flash(v)
                came_from = self.form_result.get('came_from', None)
                if came_from is None:
                    redirect(url(controller='profile', action='index'))
                else:
                    redirect(came_from.encode('utf-8'))

    def join(self):
        redirect(url(controller='home', action='login', came_from=c.came_from))

    @validate(schema=RegistrationForm(), form='join')
    def join_register(self):
        if hasattr(self, 'form_result'):
            user, email = self.__register_user(self.form_result)
            redirect(c.came_from or url(controller='profile', action='home'))

    def join_login(self):
        email = request.POST.get('login_username')
        password = request.POST.get('login_password')

        if password is not None:
            user = User.authenticate(email, password.encode('utf-8'))
            c.login_error = _('Wrong username or password!')

            if user is not None:
                sign_in_user(user)
                redirect(c.came_from or url(controller='profile', action='home'))

        return render('/login.mako')

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
