from string import strip

from formencode.api import Invalid

from sqlalchemy.sql.expression import or_

from ututi.lib.validators import TranslatedEmailValidator
from ututi.model import meta, User, UserRegistration, PendingInvitation

def make_email_invitations(emails, inviter, location=None):
    location = location or inviter.location
    invalid = []
    already = []
    invites = []
    for email in filter(bool, map(strip, emails)):
        try:
            TranslatedEmailValidator.to_python(email)
        except Invalid:
            invalid.append(email)
        else:
            if User.get(email, location):
                already.append(email)
            else:
                invitee = UserRegistration.get_by_email(email, location)
                if invitee is None:
                    invitee = UserRegistration(location, email)
                    meta.Session.add(invitee)
                invitee.inviter = inviter
                invites.append(invitee)

    return invites, invalid, already

def make_facebook_invitations(fb_ids, inviter, location=None):
    location = location or inviter.location
    already = []
    invited = []
    for facebook_id in fb_ids:
        if location and User.get_byfbid(facebook_id, location):
            already.append(facebook_id)
        else:
            invitee = UserRegistration.get_by_fbid(facebook_id, location)
            if invitee is None:
                invitee = UserRegistration(location, facebook_id=facebook_id)
                meta.Session.add(invitee)
            invitee.inviter = inviter
            invited.append(facebook_id)

    return invited

def bind_group_invitations(user):
    """Finds and binds all group invitations to user.
    Invitations are looked up by user emails and facebook_id."""

    user_emails = [email.email for email in user.emails if email.confirmed]

    invitations = meta.Session.query(PendingInvitation)\
                      .filter(or_(PendingInvitation.email.in_(user_emails),
                                  PendingInvitation.facebook_id == user.facebook_id))\
                      .filter(PendingInvitation.active == True).all()

    # filter out invitations with different location
    invitations = [i for i in invitations \
                           if i.group.location.root == user.location.root]

    for invitation in invitations:
        invitation.user = user
