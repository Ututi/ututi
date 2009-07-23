import logging

from formencode import Schema, validators, Invalid, All
from datetime import date

from pylons import request, response, c
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import email_confirmation_request
from ututi.model import meta, User, Email

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


class RegistrationForm(Schema):

    allow_extra_fields = False

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
               redirect_to(controller='home', action='home')
          else:
               return render('/anonymous_index.mako')

     def home(self):
          if c.user is not None:
               return render('/index.mako')
          else:
               abort(401, 'You are not authenticated')

     @validate(schema=RegistrationForm(), form='index')
     def register(self):
          if len(request.POST.keys()) == 0:
               redirect_to(controller='home', action='index')

          fullname = self.form_result['fullname']
          password = self.form_result['new_password']
          email = self.form_result['email'].lower()

          user = User(fullname, password)
          user.emails = [Email(email)]

          meta.Session.add(user)
          meta.Session.commit()
          email_confirmation_request(user, email)

          sign_in_user(email)

          redirect_to(controller='home', action='welcome')

     def welcome(self):
          if c.user is None:
               abort(401, 'You are not authenticated')
          c.current_year = date.today().year
          c.years = range(c.current_year - 10, c.current_year + 5)
          return  render('home/welcome.mako')
