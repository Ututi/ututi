from string import strip

from pylons.i18n import ungettext, _

from ututi.model import meta, User, UserRegistration

import ututi.lib.helpers as h

def make_email_invitations(emails, location, inviter_email=None):
    already = []
    invited = []
    for email in filter(bool, map(strip, emails)):
        if User.get(email, location):
            already.append(email)
        else:
            invitee = UserRegistration.get_by_email(email, location)
            if invitee is None:
                invitee = UserRegistration(location, email)
                meta.Session.add(invitee)
            invitee.inviter = inviter_email
            meta.Session.commit()
            invitee.send_confirmation_email()
            invited.append(email)

    if already:
        h.flash(_("%(email_list)s already using Ututi!") % \
                dict(email_list=', '.join(already)))

    if invited:
        h.flash(_("Invitations sent to %(email_list)s") % \
                dict(email_list=', '.join(invited)))

def make_facebook_invitations(fb_ids, location, inviter_email=None):
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
            invitee.inviter = inviter_email
            invited.append(facebook_id)
            meta.Session.commit()

    if already:
        h.flash(ungettext('%(num)d of your friends is already using Ututi!',
                          '%(num)d of your friends are already using Ututi!',
                          len(already)) % dict(num=len(already)))

    if invited:
        h.flash(ungettext('Invited %(num)d friend.',
                          'Invited %(num)d friends.',
                          len(invited)) % dict(num=len(invited)))
