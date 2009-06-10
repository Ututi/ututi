from pylons import request

import md5
from datetime import datetime

from ututi.lib.mailer import send_email
from pylons import config
from routes import url_for
from ututi.lib.base import render
from ututi.model import meta

from pylons.i18n import _

def current_user():
    identity = request.environ.get('repoze.who.identity')
    if identity is not None:
        user = identity.get('user')
        return user
    else:
        return None

def email_confirmation_request(user, email):
    for user_email in user.emails:
        if email.strip() == user_email.email.strip():
            hash = md5.new(datetime.now().isoformat() + email).hexdigest()
            user_email.confirmation_key = hash
            meta.Session.commit()

            link = url_for(controller='user', action='confirm_email', key=hash)
            text = render('/emails/confirm_email.mako',
                          extra_vars={'fullname' : user.fullname.decode('utf-8'), 'link' : link})
            send_email(config['ututi_email_from'], email, _('Confirm the email for Ututi'), text)
