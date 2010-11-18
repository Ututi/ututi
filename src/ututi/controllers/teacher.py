
from datetime import datetime

from pylons import url
from pylons.controllers.util import redirect
from pylons.i18n import _

from formencode import validators
from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode.compound import All
from formencode.schema import Schema

from ututi.lib.security import sign_in_user
from ututi.lib.emails import email_confirmation_request
from ututi.lib.validators import LocationTagsValidator
from ututi.lib.validators import validate
from ututi.lib.validators import UniqueEmail
from ututi.lib.validators import TranslatedEmailValidator
from ututi.lib.base import BaseController, render
from ututi.model import meta
from ututi.model.users import Email
from ututi.model.users import Teacher


class TeacherRegistrationForm(Schema):

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

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

    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator(not_empty=True))

    position = validators.String(strip=True, not_empty=True)

    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password to register.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


class TeacherController(BaseController):
    """Controller dealing with teacher registration."""
    def _registration_form(self):
        return render('/teacher/register.mako')

    @validate(schema=TeacherRegistrationForm(), form='_registration_form')
    def register(self):
        if hasattr(self, 'form_result'):
            fullname = self.form_result['fullname']
            password = self.form_result['new_password']
            email = self.form_result['email']
            location = self.form_result['location']
            position = self.form_result['position']

            teacher = Teacher(fullname=fullname,
                              password=password,
                              gen_password=True)
            teacher.emails = [Email(email)]
            teacher.accepted_terms = datetime.utcnow()
            meta.Session.add(teacher)
            meta.Session.commit()

            email_confirmation_request(teacher, email)
            sign_in_user(email)

            redirect(url(controller='profile', action='register_welcome'))

        return self._registration_form()
