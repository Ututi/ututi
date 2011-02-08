from formencode import Schema, htmlfill, validators

from pylons import tmpl_context as c, url
from pylons.controllers.util import redirect, abort

from ututi.lib.base import BaseController, render
from ututi.lib.emails import send_email_confirmation_code
from ututi.lib.validators import validate, TranslatedEmailValidator

from ututi.model import meta, LocationTag
from ututi.model.users import User, UserRegistration


class RegistrationStartForm(Schema):

    email = TranslatedEmailValidator(not_empty=True, strip=True)


class EmailApproveForm(Schema):

    hash = validators.String(min=32, max=32, strip=True)


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


class RegistrationController(BaseController):

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
