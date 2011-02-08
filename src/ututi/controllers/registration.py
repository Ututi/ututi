from formencode import Schema, htmlfill

from pylons import tmpl_context as c, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import send_email_confirmation_code
from ututi.lib.validators import validate, TranslatedEmailValidator, LocationTagsValidator

from ututi.model import meta, LocationTag
from ututi.model.users import User, UserRegistration


class RegistrationStartForm(Schema):

    email = TranslatedEmailValidator(not_empty=True, strip=True)
    location = LocationTagsValidator()

class RegistrationController(BaseController):

    def index(self, path):
        c.location = LocationTag.get(path)
        if c.location is None:
            abort(404)

        return htmlfill.render(self._start_form(),
                               defaults=dict(location=c.location.title))

    def _start_form(self):
        return render('registration/start.mako')

    @validate(schema=RegistrationStartForm(), form='_start_form')
    def start(self):
        email = self.form_result['email']
        location = self.form_result['location']

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
                                         qualified=True),
                                     registration.hash)

        return render('registration/approve.mako', extra_vars=dict(email=email))


    def approve_email(self, hash=None):
        if hash is not None:
            registration = UserRegistration.get(hash)
            if registration is not None:
                email = registration.email
                meta.Session.delete(registration)
                meta.Session.commit()
            else:
                c.registration_error = _('Bad confirmation code. Please check code and try again.')
        return render('registration/approve.mako', extra_vars=dict(email=email))
