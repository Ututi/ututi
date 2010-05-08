from pylons import tmpl_context as c, request, url
from ututi.lib.base import BaseController
from ututi.lib.base import render


class PayController(BaseController):
    """Stub pay controller for payment testing."""

    def index(self):
        c.ututi_supporters = []
        c.accepturl = request.params['accepturl']
        c.cancelurl = request.params['cancelurl']
        c.amount = int(request.params['amount']) / 100
        c.currency = request.params['currency']
        pemail = ''
        # Callback data
        params = [request.params[param].encode('UTF-8')
                  for param in ['callbackurl', 'orderid', 'projectid', 'lang',
                                'amount', 'currency', 'test']]
        [callbackurl, orderid, projectid, lang, amount, currency, test] = params

        args = ['projectid',
                'orderid',
                'lang',
                'amount',
                'currency',
                'paytext',
                '_ss2',
                '_ss1',
                'name',
                'surename',
                'status',
                'error',
                'test',
                'p_email',
                'payamount',
                'paycurrency',
                'version']

        c.callbackurl = url(
            callbackurl,
            wp_orderid=orderid,
            wp_projectid=projectid,
            wp_lang=lang,
            wp_amount=amount,
            wp_currency=currency,
            wp_paytext='Remiam remiam',
            wp__ss2='',
            wp__ss1='',
            wp_name='Jonas',
            wp_surename='Petraitis',
            wp_status='1',
            wp_pemail=pemail,
            wp_error='',
            wp_test=test)
        return render('/pay/index.mako')
