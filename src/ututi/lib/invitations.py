from string import strip

from formencode.api import Invalid

from ututi.lib.validators import TranslatedEmailValidator
from ututi.model import meta, User, UserRegistration

def make_email_invitations(emails, inviter):
    location = inviter.location
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
                meta.Session.commit()
                invites.append(invitee)

    return invites, invalid, already

def make_facebook_invitations(fb_ids, inviter):
    already = []
    invited = []
    location = inviter.location
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
            meta.Session.commit()

    return invited
