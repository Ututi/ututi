import logging

from pylons import tmpl_context as c, config, request, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _, ungettext

from ututi.model import meta, Group, User, ReceivedSMSMessage, OutgoingGroupSMSMessage
from ututi.lib.messaging import SMSMessage
from ututi.lib.base import render, BaseController
import ututi.lib.helpers as h


log = logging.getLogger(__name__)


class FortumoController(BaseController):
    """Payment by SMS."""

    def personal_sms_credits(self):
        """Buy personal SMS messages."""
        return self._receive_message('personal_sms_credits')

    def group_space(self):
        """Deposit money for group space by SMS."""
        return self._receive_message('group_space')

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
        credit_count = int(config.get('fortumo.personal_sms_credits.credits', 50))
        credit_price = float(config.get('fortumo.personal_sms_credits.price', 500)) / 100
        msg.sender.purchase_sms_credits(credit_count)
        msg.success = True
        return ungettext(
             'You have purchased %(count)d SMS credit for %(price).2f Lt;',
             'You have purchased %(count)d SMS credits for %(price).2f Lt;',
             credit_count) % dict(count=credit_count, price=credit_price) + \
           ungettext(
             ' You now have %(count)d credit.',
             ' You now have %(count)d credits.',
             msg.sender.sms_messages_remaining) % dict(count=msg.sender.sms_messages_remaining)

    def _handle_group_space(self, msg):
        group_id = msg.message_text.strip()
        group = Group.get(group_id)
        if group is None:
            return _('Invalid group: %s') % group_id

        group.purchase_days(31)

        msg.success = True
        return _('Purchased another month of group space for "%s" (until %s).'
                 ) % (group.group_id, group.private_files_lock_date.date().isoformat())

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

        max_group_members = config.get('sms_max_group_members', 40)
        if len(group.recipients_sms(sender=msg.sender)) > max_group_members:
            return ungettext(
                    'More than %d recipient, cannot send message.',
                    'More than %d recipients, cannot send message.',
                    max_group_members) % max_group_members

        # Send message.
        msg = OutgoingGroupSMSMessage(sender=msg.sender, group=group,
                                      message_text=text)
        meta.Session.add(msg)
        msg.send()

        msg.success = True
        return _('SMS message sent to group %s.') % group_id
