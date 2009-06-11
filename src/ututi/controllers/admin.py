import logging

from pylons import request, response, c
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request

from ututi.model import meta, User, Email

log = logging.getLogger(__name__)

class AdminController(BaseController):
    def index(self):
        user = current_user()
        if user is not None:
            return render('/admin/import.mako')
        else:
            return render('/anonymous_index.mako')

    def users(self):
        user = current_user()
        if user is not None:
            c.users = meta.Session.query(User).all()
            return render('/admin/users.mako')
        else:
            return render('/anonymous_index.mako')

    def import_users(self):
        file = request.POST.get('file_upload', None)
        if file is not None:
            for line in file.value.split('\n'):
                if line.strip() == '':
                    continue
                line = line.strip().split(',')
                fullname = line[2].strip()
                password = line[1].strip()[6:]
                email = line[3].strip()
                user = User(fullname, password, False)
                user.emails = [Email(email)]

                meta.Session.add(user)
                meta.Session.commit()
        redirect_to(controller='admin', action='users')
