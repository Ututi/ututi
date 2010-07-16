from pylons import tmpl_context as c, config, request, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.model import meta, Group, User
from ututi.lib.messaging import SMSMessage
from ututi.lib.base import render, BaseController
import ututi.lib.helpers as h


MAX_GROUP_MEMBERS = 40


class SmspayController(BaseController):
    """SMS payment"""

    def group_message(self):
        keyword = request.params.get('keyword')
        assert keyword == 'TXT UGR', keyword
        message_id = request.params.get('message_id')
        sig = request.params.get('sig') # TODO: check signature
        test = request.params.get('test', False)

        sender_phone = request.params.get('sender')
        message = request.params.get('message')

        sender = User.get_byphone('+' + sender_phone)
        if sender is None:
            return _('Unknown sender: +%s') % sender_phone

        group_id, text = message.split(None, 1) # XXX

        group = Group.get(group_id)
        if group is None:
            return _('Invalid group: %s') % group.title

        if not group.is_member(sender):
            return _('%s is not a member of %s') % (sender.fullname, group.title)

        if len(group.members) > MAX_GROUP_MEMBERS:
            return _('More than %d members in the group, cannot send message.') % len(group.members)

        # TODO Charge sender.

        # Send message.
        message = SMSMessage(text, sender=sender)
        group.send(message)

        #TODO: bounce in case of errors?

        meta.Session.commit()
        return _('SMS message sent to group %s.') % group_id

    def group_message_bill(self):
        print request.params
        return 'ok'
