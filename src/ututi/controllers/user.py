import logging

from pylons import request, response, c
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request

from ututi.model import meta, User, Email

log = logging.getLogger(__name__)

class UserController(BaseController):

    def index(self):
        user = current_user()
        if user is not None:
            c.fullname = user.fullname
            c.emails = [email.email.strip() for email in user.emails]
            return render('/user.mako')
        else:
            return render('/anonymous_index.mako')

    def confirm_emails(self):
        user = current_user()
        if user is not None:
            emails = request.POST.getall('email')
            for email in emails:
                email_confirmation_request(user, email)
            redirect_to(controller='user', action='index')
        else:
            redirect_to(controller='home', action='index')

