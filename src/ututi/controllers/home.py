import logging
import formencode

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort, redirect_to
from pylons.i18n import get_lang, set_lang, _
from pylons.decorators import validate

from ututi.model import User

from ututi.lib.base import BaseController, render

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
        #user = User(request.form['

        pass
