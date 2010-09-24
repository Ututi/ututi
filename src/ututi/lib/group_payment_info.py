from pylons import config
from pylons import tmpl_context as c
from pylons.i18n import _

from ututi.lib import helpers as h


class GroupPaymentInfo():
    """Stores functions for gruop payment information"""

    def group_file_limit(self):
        """Get group_file_limit"""
        return int(config.get('group_file_limit', 200 * 1024 * 1024))


    def sms_payments(self):
        """Get SMS payments."""
        if (c.user):
            payment_types = [config.get(payment_type, default)
                                   for payment_type, default in
                                       ['sms_payment1_credits', 70],
                                       ['sms_payment2_credits', 150],
                                       ['sms_payment3_credits', 350]]
            payment_amounts = [int(config.get(payment_id, default))
                                   for payment_id, default in
                                       ['sms_payment1_cost', 500],
                                       ['sms_payment2_cost', 1000],
                                       ['sms_payment3_cost', 2000]]
            payment_forms = [
                    h.mokejimai_form(
                        transaction_type='smspayment' + str(i+1),
                        amount=amount,
                        accepturl=self.url(action='members',
                                           paid_sms=payment_types[i],
                                           qualified=True),
                        cancelurl=self.url(action='members',
                                           cancelled_sms_payment=True,
                                           qualified=True),
                        orderid='%s%d_%s' % ('smspayment', i+1, c.user.id))
                             for i, amount in enumerate(payment_amounts)]
            return zip(payment_types, payment_amounts, payment_forms)


    def filearea_payments(self):
        """Get file area payments."""
        if (c.user):
            payment_types = [_('month'), _('3 months'), _('6 months')]
            payment_amounts = [int(config.get(payment_id, default))
                                           for payment_id, default in
                                               ['group_payment_month', 1000],
                                               ['group_payment_quarter', 2000],
                                               ['group_payment_halfyear', 3000]]
            payment_forms = [
                    h.mokejimai_form(
                        transaction_type='grouplimits' + str(i+1),
                        amount=amount,
                        accepturl=self.url(action='files',
                                           paid_space=payment_types[i],
                                           qualified=True),
                        cancelurl=self.url(action='files',
                                           cancelled_space_payment=True,
                                           qualified=True),
                        orderid='%s%d_%s_%s' % ('grouplimits',
                                                i+1, c.user.id, self.id))
                             for i, amount in enumerate(payment_amounts)]
            return zip(payment_types, payment_amounts, payment_forms)


