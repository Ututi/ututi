from formencode import Schema, htmlfill, validators

from pylons import tmpl_context as c, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

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

        # Otherwise create registration entry and
        # send confirmation code it to user.

        registration = UserRegistration(email, location)
        meta.Session.add(registration)
        meta.Session.commit()

        send_email_confirmation_code(email,
                                     url(controller='registration',
                                         action='approve_email',
                                         hash=registration.hash,
                                         qualified=True),
                                     registration.hash)

        redirect(url(controller='registration', action='approve_email'))


    def approve_email(self, hash=None):
        if hash is not None:
            registration = UserRegistration.get(hash)
            if registration is None:
                c.error_message = _('Bad confirmation code. Please check code and try again.')
            else:
                c.error_message = _('Good confirmation code.')

        return render('registration/approve.mako')
