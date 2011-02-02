import logging

from datetime import datetime

from pylons import session
from pylons import url
from pylons.controllers.util import redirect
from pylons import tmpl_context as c
from pylons.i18n import _

from formencode import validators
from formencode.api import Invalid
from formencode.htmlfill_schemabuilder import htmlfill
from formencode.variabledecode import NestedVariables
from formencode.compound import All
from formencode.schema import Schema

from ututi.lib.security import sign_in_user
from ututi.lib.emails import email_confirmation_request, teacher_registered_email, teacher_request_email
from ututi.lib.validators import validate
from ututi.lib.validators import TranslatedEmailValidator
from ututi.lib.base import BaseController, render
from ututi.lib import helpers as h
from ututi.model import meta, LocationTag
from ututi.model.users import User
from ututi.model.users import Email
from ututi.model.users import Teacher
from ututi.controllers.federation import FederatedRegistrationForm, FederationMixin

log = logging.getLogger(__name__)

class EmailPasswordMatchValidator(validators.FormValidator):

    messages = {
        'taken': _(u"This email address is already in use."),
    }

    def validate_python(self, form_dict, state):
        if not form_dict['new_password'] or not form_dict['email']:
            return
        user = User.get_global(form_dict['email'])
        if user is None:
            return
        if not user.checkPassword(form_dict['new_password'].encode('utf-8')):
            raise Invalid(self.message('taken', state),
                          form_dict, state,
                          error_dict={'email': Invalid(self.message('taken', state), form_dict, state)})


class TeacherRegistrationForm(Schema):

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    msg = {'missing': _(u"You must agree to the terms of use.")}
    agree = validators.StringBool(messages=msg)

    msg = {'empty': _(u"Please enter your name to register.")}
    fullname = validators.String(not_empty=True, strip=True, messages=msg)

    msg = {'non_unique': _(u"This email has already been used to register.")}
    email = All(TranslatedEmailValidator(not_empty=True, strip=True))

    msg = {'empty': _(u"Please enter your password to register."),
           'tooShort': _(u"The password must be at least 5 symbols long.")}
    new_password = validators.String(
         min=5, not_empty=True, strip=True, messages=msg)
    chained_validators = [EmailPasswordMatchValidator()]


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

            # TODO: in real registration flow, university
            # is specified explicitly
            location = LocationTag.get('uni')
            log.warn('Using default U-niversity for user registration')

            #check if this is an existing user
            existing = User.get(email, location)
            if existing is not None and existing.checkPassword(password.encode('utf-8')):
                teacher_request_email(existing)
                h.flash(_('Thank You! Your request to become a teacher has been received. We will notify You once we grant You the rights of a teacher.'))
                sign_in_user(existing)
                redirect(url(controller='profile', action='home'))

            teacher = Teacher(fullname=fullname,
                              username=email,
                              location=location,
                              password=password,
                              gen_password=True)
            teacher.emails = [Email(email)]
            teacher.accepted_terms = datetime.utcnow()
            meta.Session.add(teacher)
            meta.Session.commit()
            teacher_registered_email(teacher)
            email_confirmation_request(teacher, email)
            sign_in_user(teacher)
            h.flash(_('All teacher tools will be available to You once our team confirms You as a teacher. Thank You!'))
            redirect(url(controller='profile', action='register_welcome'))

        return self._registration_form()

    def _federated_registration_form(self):
        c.email = session.get('confirmed_email', '').lower()
        return render('teacher/federated_registration.mako')

    @validate(FederatedRegistrationForm, form='_federated_registration_form')
    def federated_registration(self):
        if not (session.get('confirmed_openid') or session.get('confirmed_facebook_id')):
            redirect(url(controller='home', action='index'))

        c.email = session.get('confirmed_email').lower()
        if hasattr(self, 'form_result'):
            # TODO: in real registration flow, university
            # is specified explicitly
            location = LocationTag.get('uni')
            log.warn('Using default U-niversity for user registration')

            user = User.get(c.email, location)
            if not user:
                # Make sure that such a user does not exist.
                user = Teacher(fullname=self.form_result['fullname'],
                               username=c.email,
                               location=location,
                               password=None,
                               gen_password=False)
                self._bind_user(user, flash=False)
                if user.facebook_id:
                    self._bind_facebook_invitations(user)
                user.accepted_terms = datetime.utcnow()
                user.emails = [Email(c.email)]
                user.emails[0].confirmed = True

                meta.Session.add(user)
                meta.Session.commit()
                teacher_registered_email(user)
                h.flash(_('All teacher tools will be available to You once our team confirms You as a teacher. Thank You!'))
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
