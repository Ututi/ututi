from formencode import Schema, htmlfill

from pylons import tmpl_context as c, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import send_email_confirmation_code
from ututi.lib.validators import validate, TranslatedEmailValidator, LocationTagsValidator

from ututi.model import meta, LocationTag
from ututi.model.users import User, PendingConfirmation


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
            # TODO: should display a message.
            redirect(location.url(action='login'))

        # Create confirmation code and send it to new user.

        confirmation = PendingConfirmation(email, location.id)
        meta.Session.add(confirmation)
        meta.Session.commit()
        send_email_confirmation_code(email,
                                     url(controller='registration',
                                         action='approve',
                                         qualified=True),
                                     confirmation.hash)
        return render('registration/approve.mako',
                      extra_vars=dict(email=email))


    def approve(self, hash=None):
        if hash is not None:
            confirmation = PendingConfirmation.get(hash)
            if confirmation is not None:
                email = confirmation.email
                meta.Session.delete(confirmation)
                meta.Session.commit()
            else:
                c.registration_error = _('Bad confirmation code. Please check code and try again.')
        return render('registration/approve.mako',
                      extra_vars=dict(email=email))
