from datetime import datetime
import hashlib
from routes import url_for

from pylons.i18n import _
from pylons import config

from ututi.lib.base import render
from ututi.model import meta
from ututi.lib.messaging import EmailMessage

def send_registration_invitation(registration, inviter=None, message=None):
    text = render('/emails/registration_invitation.mako',
                  extra_vars={'registration': registration,
                              'inviter': inviter,
                              'message': message})
    msg = EmailMessage(_('Invitation to Ututi'), text)
    msg.send(registration.email)

def send_email_confirmation_code(email, url):
    text = render('/emails/confirm_email.mako',
                  extra_vars={'link': url})

    msg = EmailMessage(_('Confirm your email for Ututi'), text, force=True)
    msg.send(email)

def email_confirmation_request(user, email):
    for user_email in user.emails:
        if email.strip() == user_email.email.strip():
            hash = hashlib.md5(datetime.now().isoformat() + email).hexdigest()
            user_email.confirmation_key = hash
            meta.Session.commit()

            link = url_for(controller='profile', action='confirm_user_email', key=hash, qualified=True)
            text = render('/emails/confirm_email.mako',
                          extra_vars={'fullname': user.fullname,
                                      'link': link,
                                      'html': False})

            msg = EmailMessage(_('Confirm the email for Ututi'), text, force=True)
            msg.send(email)

def send_group_invitation_for_user(invitation, email, message=None):
    """A method for handling user invitation to group emails."""
    from ututi.model import Email
    if invitation.user is not None:
        email_instance = Email.get(email)
        if email_instance.confirmed:
            #the user is already using ututi, send a message inviting him to join the group
            text = render('/emails/invitation_user.mako',
                          extra_vars={'invitation': invitation,
                                      'message': message})
            msg = EmailMessage(_('Ututi group invitation'), text)
            msg.send(email_instance.user)
        #if the email is not confirmed, nothing will be sent for now
        #XXX: if the user has several emails, send the invitation to one that is confirmed

def send_group_invitation_for_non_user(invitation, registration, message=None):
    """A method for handling user invitation to group emails for non users"""
    text = render('/emails/invitation_nonuser.mako',
                  extra_vars={'invitation': invitation,
                              'registration': registration,
                              'message': message})
    msg = EmailMessage(_('Ututi group invitation'), text)
    msg.send(registration.email)

def email_password_reset(user):
    """Send an email to the user with a link to reset his password."""
    text = render('/emails/password_recovery.mako',
                  extra_vars={'user' : user})
    msg = EmailMessage(_('Ututi password recovery'), text, force=True)
    user.send(msg)


def group_request_email(group, user):
    """Send an email to administrators of a group, informing of a membership request."""
    text = render('/emails/group_request.mako', extra_vars={'group': group, 'user': user})
    msg = EmailMessage(_('Ututi group membership request'), text)
    msg.send(group.administrators)

def group_confirmation_email(group, user, status):
    """Send an email to the user when his request to join a group is confirmed."""
    if status:
        #the request has been confirmed
        text = render('/emails/group_confirmation.mako', extra_vars={'group': group, 'user': user})
    else:
        text = render('/emails/group_confirmation_deny.mako', extra_vars={'group': group, 'user': user})

    msg = EmailMessage(_('Ututi group membership confirmation'), text, force=True)
    msg.send(user)


def group_space_bought_email(group):
    """Send an email to all group users when private group space are bought."""
    text = render('/emails/group_space_bought.mako', extra_vars={'group': group})
    msg = EmailMessage(_('Group space bought'), text)
    msg.send(group)

def teacher_confirmed_email(teacher, confirmed):
    """Send an email to a teacher once he has been confirmed."""
    if confirmed:
        text = render('/emails/teacher_confirmed.mako', extra_vars={'teacher': teacher, 'config':config})
    else:
        text = render('/emails/teacher_rejected.mako', extra_vars={'teacher': teacher, 'config':config})
    msg = EmailMessage(_('Your account has been confirmed!'), text, force=True)
    msg.send(teacher)

def teacher_registered_email(teacher):
    """Notify team of a new teacher."""
    text = render('/emails/teacher_registered.mako', extra_vars={'teacher': teacher})
    msg = EmailMessage(_('New teacher!'), text, force=True)
    msg.send(config.get('ututi_email_from', 'info@ututi.pl'))

    for group in teacher.location.moderator_groups:
        msg.send(group.list_address)


def teacher_request_email(user):
    """Notify team of a user requesting to become a teacher."""
    text = render('/emails/teacher_request.mako', extra_vars={'user': user})
    msg = EmailMessage(_('Request to be come a teacher!'), text, force=True)
    msg.send(config.get('ututi_email_from', 'info@ututi.pl'))

    for group in user.location.moderator_groups:
        msg.send(group.list_address)
