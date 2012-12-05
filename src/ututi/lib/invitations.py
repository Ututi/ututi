from string import strip

from formencode.api import Invalid

from ututi.lib.validators import TranslatedEmailValidator
from ututi.model import meta, User, UserRegistration, PendingInvitation
from ututi.lib.emails import send_registration_invitation

def extract_emails(emailbunch):
    """Extracts and validated emails from comma separated email list.
    Returns valid and invalid emails as separate lists."""
    valid, invalid = [], []
    for token in emailbunch.split():
        for email in filter(bool, token.split(',')):
            try:
                TranslatedEmailValidator.to_python(email)
                email.encode('ascii')
                valid.append(email)
            except (Invalid, UnicodeEncodeError):
                invalid.append(email)
    return valid, invalid

def make_email_invitations(emails, inviter, location):
    invalid = []
    already = []
    invited = []
    for email in filter(bool, map(strip, emails)):
        try:
            email = TranslatedEmailValidator.to_python(email)
        except Invalid:
            invalid.append(email)
        else:
            if User.get(email, location.root):
                already.append(email)
            else:
                invitee = UserRegistration.create_or_update(location, email)
                invitee.inviter = inviter
                invited.append(invitee)

    return invited, invalid, already

def make_facebook_invitations(fb_ids, inviter, location):
    already = []
    invited = []
    for facebook_id in fb_ids:
        if User.get_byfbid(facebook_id, location):
            already.append(facebook_id)
        else:
            invitee = UserRegistration.create_or_update(
                location, facebook_id=facebook_id)
            invitee.inviter = inviter
            invited.append(facebook_id)

    return invited

def process_registration_invitations(registration):
    inviter = registration.user
    location = registration.location
    if registration.invited_emails:
        emails = registration.invited_emails.split(',')
        invites, invalid, already = \
            make_email_invitations(emails, inviter, location)
        for invitee in invites:
            send_registration_invitation(invitee, inviter)

    if registration.invited_fb_ids:
        ids = map(int, registration.invited_fb_ids.split(','))
        make_facebook_invitations(ids, inviter, location)

def bind_group_invitations(user):
    """Finds and binds all group invitations to user.
    Invitations are looked up by user emails and facebook_id."""

    user_emails = [email.email for email in user.emails if email.confirmed]

    if not user_emails and not user.facebook_id:
        return

    query = meta.Session.query(PendingInvitation)
    if user_emails:
        query = query.filter(PendingInvitation.email.in_(user_emails))
    if user.facebook_id:
        query = query.filter(PendingInvitation.facebook_id == user.facebook_id)

    invitations = query.filter(PendingInvitation.active == True).all()

    # filter out invitations with different location
    invitations = [i for i in invitations \
                           if i.group.location.root == user.location.root]

    for invitation in invitations:
        invitation.user = user
