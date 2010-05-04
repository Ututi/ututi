import logging
from random import Random
import string
from datetime import datetime
import simplejson

from formencode import Schema, validators, Invalid, All, htmlfill
from webhelpers import paginate

from paste.util.converters import asbool
from pylons import request, tmpl_context as c, url, session, config, response
from pylons.decorators import validate
from pylons.controllers.util import abort, redirect
from pylons.i18n import _, ungettext
from pylons.templating import render_mako_def

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import func
from sqlalchemy.sql.expression import desc

from ututi.lib.base import BaseController, render, render_lang
import ututi.lib.helpers as h
from ututi.lib import gg
from ututi.lib.emails import email_confirmation_request, email_password_reset
from ututi.lib.messaging import Message
from ututi.lib.security import ActionProtector
from ututi.lib.validators import UniqueEmail
from ututi.model import meta, User, Email, PendingInvitation, LocationTag, Payment, get_supporters
from ututi.model import UserSubjectMonitoring, GroupSubjectMonitoring, Subject

log = logging.getLogger(__name__)

class PasswordRecoveryForm(Schema):
    allow_extra_fields = False
    email = All(
         validators.String(not_empty=True, strip=True),
         validators.Email()
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
    email = All(validators.Email(not_empty=True, strip=True),
                UniqueEmail(messages=msg, strip=True))

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


def sign_in_user(email):
    session['login'] = email
    session.save()

class UniversityListMixin(BaseController):
    """ A mix-in for listing all the universitites (first level location tags) in the system."""

    def _universities(self, sort_popularity=True):
        unis = meta.Session.query(LocationTag).filter(LocationTag.parent == None).order_by(LocationTag.title.asc()).all()
        if sort_popularity:
            unis.sort(key=lambda obj: obj.rating, reverse=True)
        return unis

    def _get_unis(self):
        """List all the universities in the system, paging and sorting according to request parameters."""
        c.sort = request.params.get('sort', 'popular')
        unis = self._universities(c.sort == 'popular')
        c.unis = paginate.Page(
            unis,
            page=int(request.params.get('page', 1)),
            items_per_page = 16,
            item_count = len(unis),
            **{'sort': c.sort}
            )
        c.teaser = not (request.params.has_key('page') or request.params.has_key('sort'))


class HomeController(UniversityListMixin):

    def __before__(self):
        c.ututi_supporters = get_supporters()

    def index(self):
        if c.user is not None:
            redirect(url(controller='profile', action='home'))
        else:
            self._get_unis()
            if request.params.has_key('js'):
                return render_mako_def('/anonymous_index/lt.mako','universities', unis=c.unis, ajax_url=url(controller='home', action='index'))
            c.slideshow = request.params.has_key('slide')
            return render_lang('/anonymous_index.mako')

    def about(self):
        return render_lang('/about.mako')

    def advertising(self):
        return render_lang('/advertising.mako')

    def statistics(self):
        c.most_watched_by_user = meta.Session.query(UserSubjectMonitoring.subject_id, func.count(UserSubjectMonitoring.user_id))\
            .group_by(UserSubjectMonitoring.subject_id)\
            .order_by(desc(func.count(UserSubjectMonitoring.user_id))).limit(20)
        c.most_watched_by_group = meta.Session.query(GroupSubjectMonitoring.subject_id, func.count(GroupSubjectMonitoring.group_id))\
            .group_by(GroupSubjectMonitoring.subject_id)\
            .order_by(desc(func.count(GroupSubjectMonitoring.group_id))).limit(20)

        subjects_ids, group_subjects_ids = [], []
        for a in c.most_watched_by_user: subjects_ids.append(a.subject_id)
        for a in c.most_watched_by_group: group_subjects_ids.append(a.subject_id)
 
        c.subjects = meta.Session.query(Subject)\
            .filter(Subject.id.in_(subjects_ids))
        c.group_subjects = meta.Session.query(Subject)\
            .filter(Subject.id.in_(group_subjects_ids))

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
                      'Allow: /']
            return '\n'.join(robots)

    def login(self):
        email = request.POST.get('login')
        password = request.POST.get('password')
        destination = request.params.get('came_from',
                                   url(controller='profile',
                                      action='home'))
        filename = request.params.get('context', None)

        context_type = request.params.get('context_type', None)

        if filename is not None:
            c.header = _('You have to be logged in to download a file!')
            c.message = _('After logging in you will be redirected to the download page of the file <strong>%(filename)s</strong> and the download will start automatically.') % dict(filename=filename)
            c.show_login = True
        elif context_type == 'group_join':
            c.header = _('You have to log in or register to join a group!')
            c.message = _('After logging in or registering, your request to join the group will be sent.')
            c.show_login = True
        else:
            c.header = _('Permission denied!')
            c.message = _('Only registered users can perform this action. Please log in, or register an account on our system.')
            c.show_login = False
        c.final_msg = _('If this is your first time visiting <a href="%(url)s">Ututi</a>, please register first.') % dict(url=url('/', qualified=True))

        if password is not None:
            user = None
            user = User.authenticate(email, password.encode('utf-8'))
            c.header = _('Wrong username or password!')
            c.message = _('You seem to have entered your username and password wrong, please try again!')

            if user is not None:
                sign_in_user(email)
                redirect(str(destination))

        return render('/login.mako')

    def logout(self):
        if 'login' in session:
            del session['login']
        session.save()
        redirect(url(controller='home', action='index'))

    def __register_user(self, form, send_confirmation=True):
        fullname = self.form_result['fullname']
        password = self.form_result['new_password']
        email = self.form_result['email'].lower()
        gadugadu_uin = self.form_result['gadugadu']

        user = User(fullname, password)
        user.emails = [Email(email)]
        user.accepted_terms = datetime.today()
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

        sign_in_user(email)
        return (user, email)


    @validate(schema=RegistrationForm(), form='register')
    def register(self, hash=None):
        if hasattr(self, 'form_result'):
            hash = self.form_result.get('hash', None)
            if hash is not None:
                invitation = PendingInvitation.get(hash)
                if invitation is not None and invitation.email == self.form_result['email'].lower():
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
            if hash is not None:
                c.hash = hash
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
            return render_lang('/anonymous_index.mako')

    def _pswrecovery_form(self):
        return render('home/recoveryform.mako')

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
                sign_in_user(user.emails[0].email)
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
            msg = Message(_('%(fullname)s wants you to join Ututi') % dict(fullname = c.user.fullname), text, html)

            emails = self.form_result.get('recommend_emails', '').split()
            for line in emails:
                for email in filter(bool, line.split(',')):
                    try:
                        validators.Email.to_python(email)
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
                url = self.form_result.get('came_from', None)
                if url is None:
                    redirect(url(controller='profile', action='index'))
                else:
                    redirect(url.encode('utf-8'))

    def join(self):
        return render('home/join.mako')

    @validate(schema=RegistrationForm(), form='join')
    def join_register(self):
        if hasattr(self, 'form_result'):
            user, email = self.__register_user(self.form_result)
            redirect(url(controller='group', action='add'))

    def join_login(self):
        email = request.POST.get('login_username')
        password = request.POST.get('login_password')

        if password is not None:
            user = None
            user = User.authenticate(email, password.encode('utf-8'))
            c.login_error = _('Wrong username or password!')

            if user is not None:
                sign_in_user(email)
                redirect(url(controller='group', action='add'))

        return render('/home/join.mako')

    def process_transaction(self):
        args = ['orderid',
                'merchantid',
                'lang',
                'amount',
                'currency',
                'paytext',
                '_ss2',
                '_ss1',
                'transaction2',
                'transaction',
                'payment',
                'name',
                'surename',
                'status',
                'error',
                'test',
                'user',
                'payent_type']

        kwargs = {}
        for arg in args:
            value = request.params.get(arg, '')
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
