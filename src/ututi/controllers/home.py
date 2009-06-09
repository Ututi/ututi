import logging

from formencode import Schema, validators, Invalid, All

from pylons import request, response
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render

from ututi.model import meta, User, Email

log = logging.getLogger(__name__)


class UniqueEmail(validators.FancyValidator):
     messages = {
         'empty': _(u"Enter a valid email."),
         'non_unique': _(u"The email already exists."),
         }

     def _to_python(self, value, state):
         # _to_python gets run before validate_python.  Here we
         # strip whitespace off the password, because leading and
         # trailing whitespace in a password is too elite.
         return value.strip()

     def validate_python(self, value, state):
         if value == '':
             raise Invalid(self.message("empty", state), value, state)
         elif meta.Session.query(Email).filter_by(email=value).count() > 0:
             raise Invalid(self.message("non_unique", state), value, state)


class RegistrationForm(Schema):

    allow_extra_fields = False

    msg = {'empty' : _(u"Please enter your name to register.")}
    fullname = validators.String(not_empty=True, messages=msg)

    msg = {'non_unique' : _(u"This email has already been used to register.")}
    email = All(validators.Email(not_empty=True),
                UniqueEmail(messages=msg))

    msg = {'empty' : _(u"Please enter your password to register."),
           'tooShort' : _(u"The password must be at least 5 symbols long.")}
    new_password = validators.String(min=5, not_empty=True, messages=msg)
    repeat_password = validators.String(min=5, not_empty=True, messages=msg)

    msg = {'invalid' : _(u"Passwords do not match."),
           'invalidNoMatch' : _(u"Passwords do not match."),
           'empty' : _(u"Please enter your password to register.")}
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
          identity = request.environ.get('repoze.who.identity')
          if identity is not None:
               user = identity.get('user')
               return render('/index.mako')
          else:
               return render('/anonymous_index.mako')

     @validate(schema=RegistrationForm(), form='index')
     def register(self):
          fullname = request.POST['fullname']
          password = request.POST['new_password']
          email = request.POST['email']

          user = User(fullname, password)
          user.emails = [Email(email)]

          meta.Session.add(user)
          meta.Session.commit()

          sign_in_user(email)

          redirect_to(controller='home', action='index')
