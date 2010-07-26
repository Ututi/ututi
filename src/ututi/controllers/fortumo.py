import logging

from pylons import tmpl_context as c, config, request, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.model import meta, Group, User, ReceivedSMSMessage, OutgoingGroupSMSMessage
from ututi.lib.messaging import SMSMessage
from ututi.lib.base import render, BaseController
import ututi.lib.helpers as h


log = logging.getLogger(__name__)


class FortumoController(BaseController):
    """Payment by SMS."""

    def personal_sms_credits(self):
        """Buy 100 personal SMS messages."""
        return self._receive_message('personal_sms_credits')

    def group_space_small(self):
        """Deposit money for group space by SMS."""
        return self._receive_message('group_space_small')

    def group_space_large(self):
        """Deposit money for group space by SMS."""
        return self._receive_message('group_space_large')

    def group_message(self):
        """Send a message to a group."""
        return self._receive_message('group_message')

    def billing(self):
        """Billing message handler.

        This handler is called to report successful billing for MT (Mobile
        Terminating) billing.

        MT billing is used in Lithuania; Poland uses MO (Mobile Originating)
        billing.
        """
        if request.params.get('status') != 'OK':
            # TODO: Nicer way of informing about the error?
            raise ValueError('Billing error: %s' % request.url)
        log.info('Billing notification: %s' % repr(request.url))
        return 'ok'

    def _receive_message(self, message_type):
        msg = ReceivedSMSMessage(message_type, request_url=request.url)
        msg.success = False
        msg.test = bool(request.params.get('test', False))
        msg.sender_phone_number = request.params.get('sender')
        msg.message_text = request.params.get('message')
        msg.sender = User.get_byphone('+' + msg.sender_phone_number)
        meta.Session.add(msg)
        log.info('Fortumo notification "%s" from +%s: text: %s; url: %s' % (
                msg.message_type, msg.sender_phone_number, msg.message_text,
                msg.request_url))
        if not msg.check_fortumo_sig():
            # Something fishy is going on...
            meta.Session.commit()
            raise ValueError('Invalid Fortumo signature!')

        handler = getattr(self, '_handle_%s' % message_type)
        text = handler(msg)
        msg.result = text
        meta.Session.commit()
        return text

    def _handle_personal_sms_credits(self, msg):
        if msg.sender is None:
            return _('Your phone number (+%s) is not registered in Ututi.') % msg.sender_phone_number
        msg.sender.sms_messages_remaining += 100
        msg.success = True
        return _('You have purchased 100 SMS messages for 10 Lt; now you have %d messages.') % msg.sender.sms_messages_remaining

    def _handle_group_space_small(self, msg):
        return self._handle_group_space(msg, value=2)

    def _handle_group_space_large(self, msg):
        return self._handle_group_space(msg, value=10)

    def _handle_group_space(self, msg, value):
        group_id = msg.message_text.strip()
        group = Group.get(group_id)
        if group is None:
            return _('Invalid group: %s') % group_id

        group.private_files_credits += value

        msg.success = True
        return _('Added %d credits to group space account; now there are %d.'
                 ) % (value, group.private_files_credits)

    def _handle_group_message(self, msg):
        parts = msg.message_text.split(None, 1)
        if len(parts) != 2:
            return _('Invalid group message: %s') % msg.message_text

        group_id, text = parts

        if not msg.sender:
            return _('The phone number %s is not associated with a Ututi user') % (msg.sender_phone_number)

        group = Group.get(group_id)
        if group is None:
            return _('Invalid group: %s') % group_id

        # Send message.
        msg = OutgoingGroupSMSMessage(sender=msg.sender, group=group,
                                      message_text=text)
        meta.Session.add(msg)
        msg.send()

        msg.success = True
        return _('SMS message sent to group %s.') % group_id
