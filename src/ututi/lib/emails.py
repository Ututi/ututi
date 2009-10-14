from datetime import datetime
import md5
from routes import url_for

from pylons.i18n import _

from ututi.lib.base import render
from ututi.model import meta
from ututi.lib.messaging import Message

def email_confirmation_request(user, email):
    for user_email in user.emails:
        if email.strip() == user_email.email.strip():
            hash = md5.new(datetime.now().isoformat() + email).hexdigest()
            user_email.confirmation_key = hash
            meta.Session.commit()

            link = url_for(controller='profile', action='confirm_user_email', key=hash, qualified=True)
            text = render('/emails/confirm_email.mako',
                          extra_vars={'fullname': user.fullname,
                                      'link': link,
                                      'html': False})

            msg = Message(_('Confirm the email for Ututi'), text, force=True)
            msg.send(email)


def group_invitation_email(invitation, email):
    """A method for handling user invitation to group emails."""
    from ututi.model import Email
    if invitation.user is not None:
        email_instance = Email.get(email)
        if email_instance.confirmed:
            #the user is already using ututi, send a message inviting him to join the group
            text = render('/emails/invitation_user.mako',
                          extra_vars={'invitation': invitation})
            msg = Message(_('Ututi group invitation'), text)
            msg.send(email_instance.user)
        #if the email is not confirmed, nothing will be sent for now
        #XXX: if the user has several emails, send the invitation to one that is confirmed
    else:
        #the person invited is not a ututi user

        text = render('/emails/invitation_nonuser.mako',
                      extra_vars={'invitation': invitation})

        msg = Message(_('Ututi group invitation'), text)
        msg.send(email)


def email_password_reset(user, email):
    """Send an email to the user with a link to reset his password."""
    text = render('/emails/password_recovery.mako',
                  extra_vars={'user' : user})
    msg = Message(_('Ututi password recovery'), text, force=True)
    user.send(msg)


def group_request_email(group, user):
    """Send an email to administrators of a group, informing of a membership request."""
    text = render('/emails/group_request.mako', extra_vars={'group': group, 'user': user})
    msg = Message(_('Ututi group membership request'), text)
    msg.send(group.administrators)

def group_confirmation_email(group, user, status):
    """Send an email to the user when his request to join a group is confirmed."""
    if status:
        #the request has been confirmed
        text = render('/emails/group_confirmation.mako', extra_vars={'group': group, 'user': user})
    else:
        text = render('/emails/group_confirmation_deny.mako', extra_vars={'group': group, 'user': user})

    msg = Message(_('Ututi group membership confirmation'), text)
    msg.send(user)
