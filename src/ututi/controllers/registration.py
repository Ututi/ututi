import cgi

from formencode import Schema, htmlfill, validators

from pylons import tmpl_context as c, url, session, request
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import send_email_confirmation_code
from ututi.lib.validators import validate, TranslatedEmailValidator
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


def location_action(method):
    def _location_action(self, path):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.location = location
        return method(self, location)
    return _location_action


def registration_action(method):
    def _registration_action(self, hash):
        registration = UserRegistration.get(hash)

        if registration is None:
            abort(404)

        c.registration = registration
        return method(self, registration)
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
                if registration.email != email:
                    # TODO: we probably want to store user's email
                    pass
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
        c.registration.openid = None
        meta.Session.commit()
        h.flash(_('Unlinked from Google account.'))
        redirect(url(controller='registration',
                     action='personal_info',
                     hash=registration.hash))


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
            return render('registration/email_approval.mako')

    def confirm_email(self, hash):
        if hash is not None:
            registration = UserRegistration.get(hash)
            if registration is None:
                abort(404)
            else:
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

        return render('registration/university_info.mako')

    @registration_action
    @validate(schema=PersonalInfoForm(), form='personal_info')
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
        return htmlfill.render(render('registration/personal_info.mako'),
                               defaults=defaults)

    @registration_action
    def add_photo(self, registration):
        return render('registration/add_photo.mako')
