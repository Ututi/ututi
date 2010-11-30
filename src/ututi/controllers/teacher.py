
from datetime import datetime

from pylons import request
from pylons import session
from pylons import url
from pylons.controllers.util import redirect
from pylons import tmpl_context as c
from pylons.i18n import _

from formencode import validators
from formencode.htmlfill_schemabuilder import htmlfill
from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode.compound import All
from formencode.schema import Schema

from ututi.lib.security import sign_in_user
from ututi.lib.emails import email_confirmation_request, teacher_registered_email
from ututi.lib.validators import LocationTagsValidator
from ututi.lib.validators import validate
from ututi.lib.validators import UniqueEmail
from ututi.lib.validators import TranslatedEmailValidator
from ututi.lib.base import BaseController, render
from ututi.model import PendingInvitation
from ututi.model import meta
from ututi.model.users import User
from ututi.model.users import Email
from ututi.model.users import Teacher
from ututi.controllers.federation import FederatedRegistrationForm, FederationMixin

class TeacherFederatedRegistrationForm(FederatedRegistrationForm):
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator(not_empty=True))

    position = validators.String(strip=True, not_empty=True)


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


class TeacherController(BaseController, FederationMixin):
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
            teacher.teacher_position = position
            teacher.emails = [Email(email)]
            teacher.location = location
            teacher.accepted_terms = datetime.utcnow()
            meta.Session.add(teacher)
            meta.Session.commit()
            teacher_registered_email(teacher)
            email_confirmation_request(teacher, email)
            sign_in_user(teacher)

            redirect(url(controller='profile', action='register_welcome'))

        return self._registration_form()

    def _federated_registration_form(self):
        c.email = session.get('confirmed_email', '').lower()
        return render('teacher/federated_registration.mako')

    @validate(TeacherFederatedRegistrationForm, form='_federated_registration_form')
    def federated_registration(self):
        if not (session.get('confirmed_openid') or session.get('confirmed_facebook_id')):
            redirect(url(controller='home', action='index'))
        c.email = session.get('confirmed_email').lower()
        if hasattr(self, 'form_result'):
            user = User.get(c.email)
            if not user:
                # Make sure that such a user does not exist.
                user = Teacher(fullname=self.form_result['fullname'],
                               password=None,
                               gen_password=False)
                self._bind_user(user, flash=False)
                if user.facebook_id:
                    self._bind_facebook_invitations(user)
                user.teacher_position = self.form_result['position']
                user.accepted_terms = datetime.utcnow()
                user.emails = [Email(c.email)]
                user.emails[0].confirmed = True

                user.location = self.form_result['location']

                meta.Session.add(user)
                meta.Session.commit()
                teacher_registered_email(user)
                sign_in_user(user)

            kwargs = dict()
            if user.facebook_id:
                kwargs['fb'] = True

            redirect(c.came_from or url(controller='profile',
                                        action='register_welcome', **kwargs))

        # Render form: suggested name, suggested email, agree with conditions
        defaults = dict(fullname=session.get('confirmed_fullname'),
                    email=c.email)
        return htmlfill.render(self._federated_registration_form(),
                               defaults=defaults)
