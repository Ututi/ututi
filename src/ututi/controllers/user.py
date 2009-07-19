import logging

from formencode import Schema, validators
from routes import url_for

from pylons import request, c
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import email_confirmation_request

from ututi.model import meta, Email, File

log = logging.getLogger(__name__)


class ProfileForm(Schema):
    """A schema for validating user profile forms."""
    allow_extra_fields = True
    fullname = validators.String(not_empty=True)


class UserController(BaseController):
    """A controller for the user's information and actions."""

    def index(self):
        if c.user is not None:
            c.fullname = c.user.fullname
            c.emails = [email.email for email in
                        meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=False).all()]
            c.emails_confirmed = [email.email for email in
                                  meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=True).all()]
            return render('/user.mako')
        else:
            return render('/anonymous_index.mako')

    def edit(self):
        if c.user is None:
            abort(401, 'You are not authenticated')

        c.breadcrumbs = [
            {'title': c.user.fullname,
             'link': url_for(controller='user', action='index', id=c.user.id)},
            {'title': _('Edit'),
             'link': url_for(controller='user', action='edit', id=c.user.id)}
            ]

        return render('user/edit.mako')

    @validate(ProfileForm, form='edit')
    def update(self):
        fields = ('fullname', 'logo_upload', 'logo_delete')
        values = {}

        for field in fields:
            values[field] = request.POST.get(field, None)

        c.user.fullname = values['fullname']

        if values['logo_delete'] == 'delete' and c.user.logo is not None:
            meta.Session.delete(c.user.logo)
            c.user.logo = None

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            f = File(logo.filename, 'Avatar for %s' % c.user.fullname, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)
            if c.user.logo is not None:
                meta.Session.delete(c.user.logo)
            c.user.logo = f

        meta.Session.commit()
        redirect_to(controller='user', action='index')

    def confirm_emails(self):
        if c.user is not None:
            emails = request.POST.getall('email')
            for email in emails:
                email_confirmation_request(c.user, email)
            redirect_to(controller='user', action='index')
        else:
            redirect_to(controller='home', action='index')

    def confirm_user_email(self, key):
        email = meta.Session.query(Email).filter_by(confirmation_key=key).first()
        email.confirmed = True
        email.confirmation_key = ''
        meta.Session.commit()
        redirect_to(controller='user', action='index')
