import logging

from pylons import tmpl_context as c, config, request, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.model import meta, Group, User, ReceivedSMSMessage, OutgoingGroupSMSMessage
from ututi.lib.messaging import SMSMessage
from ututi.lib.base import render, BaseController
import ututi.lib.helpers as h


log = logging.getLogger(__name__)




class SmspayController(BaseController):
    """SMS payment."""

    def group_message(self):
        self.received_message = ReceivedSMSMessage('paid_group_message',
                                                   request_url=request.url)
        meta.Session.add(self.received_message)

        message = self._handle_group_message()

        self.received_message.result = message
        meta.Session.commit()

        return message

    def _handle_group_message(self):
        recv = self.received_message
        recv.success = False

        recv.test = request.params.get('test', False)

        message = request.params.get('message')
        recv.message_text = message

        sender_phone = request.params.get('sender')
        recv.sender_phone_number = sender_phone

        sender = User.get_byphone('+' + sender_phone)
        recv.sender = sender

        if not self.received_message.check_fortumo_sig():
            # Something fishy is going on...
            meta.Session.commit()
            raise ValueError('Invalid Fortumo signature!')

        if sender is None:
            return _('Unknown sender: +%s') % sender_phone

        parts = message.split(None, 1)
        if len(parts) != 2:
            return _('Invalid group message: %s') % message

        group_id, text = parts

        group = Group.get(group_id)
        if group is None:
            return _('Invalid group: %s') % group.title

        if not group.is_member(sender):
            return _('%s is not a member of %s') % (sender.fullname, group.title)

        max_group_members = config.get('sms_max_group_members', 40)
        if len(group.members) > MAX_GROUP_MEMBERS:
            return _('More than %d members in the group, cannot send message.'
                     ) % MAX_GROUP_MEMBERS

        # Send message.
        msg = OutgoingGroupSMSMessage(sender=sender, group=group,
                                      message_text=text)
        meta.Session.add(msg)
        msg.send()

        recv.success = True
        return _('SMS message sent to group %s.') % group_id

    def group_message_bill(self):
        """Billing message handler.

        This handler is called to report successful billing for MT (Mobile
        Terminating) billing.

        MT billing is used in Lithuania; Poland uses MO (Mobile Originating)
        billing.
        """
        log.info('SMS MT billing report: ' + repr(request.params))
        # TODO
        return 'ok'
