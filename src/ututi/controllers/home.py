import logging
from random import Random
import string

from routes.util import redirect_to
from formencode import Schema, validators, Invalid, All

from pylons import request, response, c
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _

from sqlalchemy.orm.exc import NoResultFound

from ututi.lib.base import BaseController, render
import ututi.lib.helpers as h
from ututi.lib.emails import email_confirmation_request, email_password_reset

from ututi.model import meta, User, Email, PendingInvitation

log = logging.getLogger(__name__)

class UniqueEmail(validators.FancyValidator):

     messages = {
         'empty': _(u"Enter a valid email."),
         'non_unique': _(u"The email already exists."),
         }

     def validate_python(self, value, state):
         if value == '':
             raise Invalid(self.message("empty", state), value, state)
         elif meta.Session.query(Email).filter_by(email=value).count() > 0:
             raise Invalid(self.message("non_unique", state), value, state)


class PasswordRecoveryForm(Schema):
     allow_extra_fields = False
     email = validators.Email()


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

    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password to register.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


def sign_in_user(email):
     identity = {'repoze.who.userid': email}
     headers = request.environ['repoze.who.plugins']['auth_tkt'].remember(
          request.environ,
          identity)
     for k, v in headers:
          response.headers.add(k, v)


class HomeController(BaseController):

     def index(self):
          if c.user is not None:
               redirect_to(controller='profile', action='home')
          else:
               return render('/anonymous_index.mako')


     @validate(schema=RegistrationForm(), form='register')
     def register(self, hash=None):
          if hasattr(self, 'form_result'):
               fullname = self.form_result['fullname']
               password = self.form_result['new_password']
               email = self.form_result['email'].lower()

               user = User(fullname, password)
               user.emails = [Email(email)]

               meta.Session.add(user)
               meta.Session.commit()
               email_confirmation_request(user, email)

               sign_in_user(email)
               hash = self.form_result.get('hash', None)
               if hash is not None:
                    invitation = PendingInvitation.get(hash)
                    if invitation is not None and invitation.email == email:
                         invitation.group.add_member(user)
                         meta.Session.delete(invitation)
                         meta.Session.commit()
                         redirect_to(controller='group', action='group_home', id=invitation.group.group_id)
               else:
                    redirect_to(controller='profile', action='welcome')
          else:
               if hash is not None:
                    c.hash = hash
               return render('register.mako')

     @validate(PasswordRecoveryForm, form='pswrecovery')
     def pswrecovery(self):
          if hasattr(self, 'form_result'):
               email = self.form_result.get('email', None)
               user = User.get(email)
               if user is not None:
                    user.recovery_key = ''.join(Random().sample(string.ascii_lowercase, 8))
                    email_password_reset(user, email)
                    meta.Session.commit()
                    h.flash(_('Password recovery email sent. Please check You inbox.'))
               else:
                    h.flash(_('User account not found.'))
          return render('home/recoveryform.mako')

     @validate(PasswordResetForm, form='recovery')
     def recovery(self, key=None):
          try:
               if hasattr(self, 'form_result'):
                    c.key = self.form_result.get('recovery_key', '')
                    user = meta.Session.query(User).filter(User.recovery_key == c.key).one()
                    user.update_password(self.form_result.get('new_password'))
                    user.recovery_key = None
                    meta.Session.commit()
                    h.flash(_('Your password has been updated. Welcome back!'))
                    sign_in_user(user.emails[0].email)
                    redirect_to(controller='profile', action='index')
               else:
                    c.key = key
                    user = meta.Session.query(User).filter(User.recovery_key == c.key).one()

               return render('home/password_resetform.mako')
          except NoResultFound:
               abort(404)
