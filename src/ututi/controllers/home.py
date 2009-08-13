import logging

from formencode import Schema, validators, Invalid, All
from datetime import date

from pylons import request, response, c
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from webhelpers import paginate

from ututi.lib.base import BaseController, render
from ututi.lib.emails import email_confirmation_request
from ututi.lib.search import search_query
from ututi.model import meta, User, Email, Group, SearchItem, ContentItem, LocationTag
from ututi.controllers.search import SearchSubmit

log = logging.getLogger(__name__)

def location_filter(location_tag):
     def _filter(query):
          return query.filter(ContentItem.location == location_tag)
     return _filter

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
               redirect_to(controller='profile', action='home')
          else:
               return render('/anonymous_index.mako')

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

     @validate(schema=SearchSubmit, form='test', post_only = False, on_get = True)
     def findgroup(self):
          """Find the requested group, filtering by location id and year."""
          #collect default search parameters
          c.text = self.form_result.get('text', '')
          c.tags = self.form_result.get('tagsitem', None)
          if c.tags is None:
               c.tags = self.form_result.get('tags', '').split(', ')
          c.tags.extend(self.form_result.get('location', []))
          c.tags = filter(bool, c.tags)

          #extra search parameters
          c.year = self.form_result.get('year', None)

          search_params = {}
          if c.text:
               search_params['text'] = c.text
          if c.tags:
               search_params['tags'] = c.tags
          else:
               search_params['tags'] = []

          search_params['obj_type'] = 'group'

          if search_params != {}:
               results = search_query(**search_params)

               if c.year is not None:
                    search_params['year'] = c.year
                    results = results.join((Group, SearchItem.content_item_id == Group.id))\
                        .filter(Group.year == date(int(c.year), 1, 1))

          c.year = c.year and int(c.year) or date.today().year
          c.years = range(date.today().year - 10, date.today().year + 5)
          c.tags = ', '.join(c.tags)

          c.results = paginate.Page(
               results,
               page=int(request.params.get('page', 1)),
               items_per_page = 10,
               **search_params)

          return render('home/findgroup.mako')
