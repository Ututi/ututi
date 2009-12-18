from pylons import tmpl_context as c, request, url
from ututi.lib.base import BaseController
from ututi.lib.base import render


class PayController(BaseController):
    """Stub pay controller for payment testing."""

    def index(self):
        c.accepturl = request.params['accepturl']
        c.cancelurl = request.params['cancelurl']
        c.amount = int(request.params['amount']) / 100
        c.currency = request.params['currency']

        # Callback data
        params = [request.params[param].encode('UTF-8')
                  for param in ['callbackurl', 'orderid', 'merchantid', 'lang',
                                'amount', 'currency', 'test']]
        [callbackurl, orderid, merchantid, lang, amount, currency, test] = params

        c.callbackurl = url(
            callbackurl,
            orderid=orderid,
            merchantid=merchantid,
            lang=lang,
            amount=amount,
            currency=currency,
            paytext='Remiam remiam',
            _ss2='',
            _ss1='',
            transaction2='',
            transaction='',
            payment='Snoras',
            name='Jonas',
            surename='Petraitis',
            status='1',
            error='',
            test=test)
        return render('/pay/index.mako')
