import cgi
import facebook

from formencode import Schema, htmlfill, validators
from formencode.foreach import ForEach
from formencode.compound import Pipe

from pylons import tmpl_context as c, url, session, request, config
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import send_email_confirmation_code
from ututi.lib.image import serve_logo
from ututi.lib.validators import validate, TranslatedEmailValidator, \
        FileUploadTypeValidator, CommaSeparatedListValidator
import ututi.lib.helpers as h

from ututi.model import meta, LocationTag
from ututi.model.users import User, UserRegistration

from openid.consumer import consumer
from openid.consumer.consumer import Consumer, DiscoveryFailure
from openid.extensions import ax

from xml.sax.saxutils import quoteattr


class RegistrationStartForm(Schema):

    email = TranslatedEmailValidator(not_empty=True, strip=True)


class EmailApproveForm(Schema):

    hash = validators.String(min=32, max=32, strip=True)


class PersonalInfoForm(Schema):

    msg = {'empty': _(u"Please enter your full name.")}
    fullname = validators.String(not_empty=True, strip=True, messages=msg)
    msg = {'empty': _(u"Please enter your password."),
           'tooShort': _(u"Password must be at least 5 characters long.")}
    password = validators.String(
         min=5, not_empty=True, strip=True, messages=msg)


class AddPhotoForm(Schema):

    allowed_types = ('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif')
    msg = {'empty': _(u"Please select your photo.")}
    photo = FileUploadTypeValidator(allowed_types=allowed_types,
                                    not_empty=True,
                                    messages=msg)


class EmailAddSuffix(validators.FancyValidator):

    def _to_python(self, value, state):
        if isinstance(value, basestring):
            value = value.strip()
        if value:
            _, _, suffix = c.registration.email.partition('@')
            value = '%s@%s' % (value, suffix)
        return value


class InviteFriendsForm(Schema):
    """There are two variants of the form, this schema handles both."""

    email1 = Pipe(EmailAddSuffix(), TranslatedEmailValidator())
    email2 = Pipe(EmailAddSuffix(), TranslatedEmailValidator())
    email3 = Pipe(EmailAddSuffix(), TranslatedEmailValidator())
    email4 = Pipe(EmailAddSuffix(), TranslatedEmailValidator())
    email5 = Pipe(EmailAddSuffix(), TranslatedEmailValidator())

    emails = Pipe(validators.String(),
                  CommaSeparatedListValidator(),
                  ForEach(validators.Email()))


def location_action(method):
    def _location_action(self, path):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.location = location
        return method(self, location)
    return _location_action


def registration_action(method):
    def _registration_action(self, hash, *args):
        registration = UserRegistration.get_by_hash(hash)

        if registration is None or registration.completed:
            abort(404)

        c.registration = registration

        c.steps = [
            ('university_info', _("University information")),
            ('personal_info', _("Personal information")),
            ('add_photo', _("Add your photo")),
            ('invite_friends', _("Invite friends")),
        ]

        c.active_step = None

        return method(self, registration, *args)
    return _registration_action


class FederationMixin(object):

    @registration_action
    def link_google(self, registration):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)

        GOOGLE_OPENID = 'https://www.google.com/accounts/o8/id'
        try:
            authrequest = cons.begin(GOOGLE_OPENID)
        except DiscoveryFailure:
            h.flash(_('Authentication failed, please try again.'))
            redirect(url(controller='registration',
                         action='personal_info',
                         hash=registration.hash))

        ax_req = ax.FetchRequest()
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/first',
                               alias='firstname', required=True))
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/last',
                               alias='lastname', required=True))
        ax_req.add(ax.AttrInfo('http://schema.openid.net/contact/email',
                               alias='email', required=True))
        authrequest.addExtension(ax_req)

        session['openid_session'] = openid_session
        session.save()

        realm = url(controller='home', action='index', qualified=True)
        return_to = url(controller='registration', action='google_verify',
                        hash=registration.hash, qualified=True)

        redirect(authrequest.redirectURL(realm, return_to))

    @registration_action
    def google_verify(self, registration):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)

        current_url = url(controller='registration', action='google_verify',
                         hash=registration.hash, qualified=True)
        info = cons.complete(request.params, current_url)

        display_identifier = info.getDisplayIdentifier()

        if info.status == consumer.SUCCESS:
            identity_url = info.identity_url
            if User.get_byopenid(identity_url, registration.location):
                message = _('This Google account is already linked to another Ututi account.')
            else:
                registration.openid = identity_url
                if not registration.fullname:
                    registration.fullname = '%s %s' % (
                        request.params.get('openid.ext1.value.firstname'),
                        request.params.get('openid.ext1.value.lastname'))
                email = request.params.get('openid.ext1.value.email')
                registration.openid_email = email
                meta.Session.commit()
                message = _('Linked to Google account.')
        elif info.status == consumer.FAILURE and display_identifier:
            # In the case of failure, if info is non-None, it is the
            # URL that we were verifying. We include it in the error
            # message to help the user figure out what happened.
            fmt = _("Verification of %s failed: %s")
            message = fmt % (display_identifier, cgi.escape(info.message))
        elif info.status == consumer.CANCEL:
            message = _('Verification cancelled')
        elif info.status == consumer.SETUP_NEEDED:
            if info.setup_url:
                message = _('<a href=%s>Setup needed</a>') % quoteattr(info.setup_url),
            else:
                # This means auth didn't succeed, but you're welcome to try
                # non-immediate mode.
                message = _('Setup needed')
        else:
            message = _('Authentication failed: %s') % info.message
            # TODO: log info.status and info.message

        h.flash(message)
        redirect(url(controller='registration',
                     action='personal_info',
                     hash=registration.hash))

    @registration_action
    def unlink_google(self, registration):
        registration.openid = None
        meta.Session.commit()
        h.flash(_('Unlinked from Google account.'))
        redirect(url(controller='registration',
                     action='personal_info',
                     hash=registration.hash))

    @registration_action
    def link_facebook(self, registration):
        fb_user = facebook.get_user_from_cookie(request.cookies,
                         config['facebook.appid'], config['facebook.secret'])
        if not fb_user:
            h.flash(_("Failed to link Facebook account"))
        else:
            facebook_id = int(fb_user['uid'])
            if not User.get_byfbid(facebook_id, registration.location):
                registration.facebook_id = facebook_id
                registration.update_logo_from_facebook()
                meta.Session.commit()
                h.flash(_("Linked to Facebook account."))
            else:
                h.flash(_('This Facebook account is already linked to another user.'))
        redirect(url(controller='registration', action='personal_info', hash=registration.hash))

    @registration_action
    def unlink_facebook(self, registration):
        registration.facebook_id = None
        meta.Session.commit()
        h.flash(_('Unlinked from Facebook account.'))
        redirect(url(controller='registration', action='personal_info', hash=registration.hash))


class RegistrationController(BaseController, FederationMixin):

    def _start_form(self):
        return render('registration/start.mako')

    def _send_confirmation(self, registration):
        """Shorthand method."""
        send_email_confirmation_code(registration.email,
                                     url(controller='registration',
                                         action='confirm_email',
                                         hash=registration.hash,
                                         qualified=True),
                                     registration.hash)


    @location_action
    @validate(schema=RegistrationStartForm(), form='_start_form')
    def start(self, location):

        if not hasattr(self, 'form_result'):
            return htmlfill.render(self._start_form())

        email = self.form_result['email']

        if User.get(email, location):
            # User with this email exists in this location.
            # TODO: here we should display a message, and
            # ask user if he wants us to remember his password.
            redirect(location.url(action='login'))

        # Otherwise lookup/create registration entry and
        # send confirmation code it to user.

        registration = UserRegistration.get_by_email(email)
        if registration is None:
            registration = UserRegistration(email, location)
            meta.Session.add(registration)
            meta.Session.commit()

        self._send_confirmation(registration)

        c.email = email
        return render('registration/email_approval.mako')

    @validate(schema=RegistrationStartForm(), form='resend_code')
    def resend_code(self):
        if not hasattr(self, 'form_result'):
            abort(404)

        email = self.form_result['email']
        registration = UserRegistration.get_by_email(email)
        if registration is None:
            abort(404)
        else:
            c.email = email
            self._send_confirmation(registration)
            h.flash(_("Your confirmation code was resent."))
            return render('registration/email_approval.mako')

    @registration_action
    def confirm_email(self, registration):
        registration.email_confirmed = True
        meta.Session.commit()
        redirect(url(controller='registration', action='university_info',
                     hash=registration.hash))

    @registration_action
    def university_info(self, registration):
        # this may have to be rewritten
        from random import shuffle
        count = 14
        all_users = registration.location.users
        with_logo = [u for u in all_users if u.has_logo()]
        and_other = [u for u in all_users if not u.has_logo()]
        shuffle(with_logo)
        if len(with_logo) >= count:
            c.users = with_logo[:count]
        else:
            c.users = with_logo + and_other[:count - len(with_logo)]

        c.active_step = 'university_info'
        return render('registration/university_info.mako')

    def _personal_info_form(self):
        c.active_step = 'personal_info'
        return render('registration/personal_info.mako')

    @registration_action
    @validate(schema=PersonalInfoForm(), form='_personal_info_form')
    def personal_info(self, registration):
        if hasattr(self, 'form_result'):
            registration.fullname = self.form_result['fullname']
            registration.update_password(self.form_result['password'])
            meta.Session.commit()
            redirect(url(controller='registration', action='add_photo',
                         hash=registration.hash))

        defaults = {
            'fullname': registration.fullname,
        }
        return htmlfill.render(self._personal_info_form(), defaults=defaults)

    @registration_action
    @validate(schema=AddPhotoForm(), form='add_photo')
    def add_photo(self, registration):
        if hasattr(self, 'form_result'):
            photo = self.form_result['photo']
            registration.logo = photo.file.read()
            meta.Session.commit()
            if request.params.has_key('js'):
                return 'OK'
            else:
                redirect(url(controller='registration',
                             action='invite_friends',
                             hash=registration.hash))

        c.active_step = 'add_photo'
        return render('registration/add_photo.mako')

    @registration_action
    @validate(schema=InviteFriendsForm(), form='invite_friends')
    def invite_friends(self, registration):
        if hasattr(self, 'form_result'):
            emails = [self.form_result['email1'],
                      self.form_result['email2'],
                      self.form_result['email3'],
                      self.form_result['email4'],
                      self.form_result['email5']] + self.form_result['emails']

            self._send_invitations(registration, emails)

            redirect(url(controller='registration', action='finish',
                         hash=registration.hash))

        _, _, suffix = registration.email.partition('@')
        c.email_suffix = '@' + suffix
        c.active_step = 'invite_friends'
        return render('registration/invite_friends.mako')

    def _send_invitations(self, registration, emails):
        already = []
        invited = []
        for email in filter(bool, emails):
            if User.get(email, registration.location):
                already.append(email)
            else:
                invitee = UserRegistration.get_by_email(email)
                if invitee is None:
                    invitee = UserRegistration(email, registration.location)
                    meta.Session.add(invitee)
                invitee.inviter = email
                meta.Session.commit()
                self._send_confirmation(invitee)
                invited.append(email)

        if already:
            h.flash(_("%(email_list)s already using Ututi!") % \
                    dict(email_list=', '.join(already)))

        if invited:
            h.flash(_("Invitations sent to %(email_list)s") % \
                    dict(email_list=', '.join(invited)))

    @registration_action
    def finish(self, registration):
        from ututi.lib.security import sign_in_user
        user = registration.create_user()
        meta.Session.add(user)
        registration.completed = True
        meta.Session.commit()
        sign_in_user(user)
        redirect(url(controller='profile', action='register_welcome'))

    def logo(self, id, size):
        return serve_logo('registration', id, width=size, height=size,
                          default_img_path="public/img/user_default.png",
                          cache=False)
