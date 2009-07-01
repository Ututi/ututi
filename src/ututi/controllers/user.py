import logging

from pylons import request, c
from pylons.controllers.util import redirect_to

from ututi.lib.base import BaseController, render
from ututi.lib import current_user
from ututi.lib.emails import email_confirmation_request

from ututi.model import meta, Email

log = logging.getLogger(__name__)

class UserController(BaseController):

    def index(self):
        user = current_user()
        if user is not None:
            c.fullname = user.fullname
            c.emails = [email.email for email in
                        meta.Session.query(Email).filter_by(id=user.id).filter_by(confirmed=False).all()]
            c.emails_confirmed = [email.email for email in
                                  meta.Session.query(Email).filter_by(id=user.id).filter_by(confirmed=True).all()]
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

    def confirm_user_email(self, key):
        email = meta.Session.query(Email).filter_by(confirmation_key=key).first()
        email.confirmed = True
        email.confirmation_key = ''
        meta.Session.commit()
        redirect_to(controller='user', action='index')
