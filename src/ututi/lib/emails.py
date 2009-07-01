from datetime import datetime
import md5
from routes import url_for

from pylons import config
from pylons.i18n import _

from ututi.lib.mailer import send_email
from ututi.lib.base import render
from ututi.model import meta

def email_confirmation_request(user, email):
    for user_email in user.emails:
        if email.strip() == user_email.email.strip():
            hash = md5.new(datetime.now().isoformat() + email).hexdigest()
            user_email.confirmation_key = hash
            meta.Session.commit()

            link = url_for(controller='user', action='confirm_user_email', key=hash, qualified=True)
            text = render('/emails/confirm_email.mako',
                          extra_vars={'fullname' : user.fullname.decode('utf-8'), 'link' : link})
            send_email(config['ututi_email_from'], email, _('Confirm the email for Ututi'), text)
