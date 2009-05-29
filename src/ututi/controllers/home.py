import logging
import formencode

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort, redirect_to
from pylons.i18n import get_lang, set_lang, _
from pylons.decorators import validate

from ututi.lib.base import BaseController, render

from ututi.model import meta, User, Email

log = logging.getLogger(__name__)

class RegistrationForm(formencode.Schema):
    allow_extra_fields = True
    email = formencode.validators.Email(not_empty=True)
    new_password = formencode.validators.String()
    repeat_password = formencode.validators.String()
    chained_validators = [formencode.validators.FieldsMatch('new_password', 'repeat_password')]

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

        identity = {'repoze.who.userid': email}
        headers = request.environ['repoze.who.plugins']['auth_tkt'].remember(
            request.environ, 
            identity)
        for k, v in headers:
            response.headers.add(k, v)

        redirect_to(controller='home', action='index')
