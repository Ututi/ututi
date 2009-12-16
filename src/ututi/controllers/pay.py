from pylons import tmpl_context as c, request
from ututi.lib.base import BaseController
from ututi.lib.base import render


class PayController(BaseController):
    """Stub pay controller for payment testing."""

    def index(self):
        c.accepturl = request.params['accepturl']
        c.cancelurl = request.params['cancelurl']
        c.callbackurl = request.params['callbackurl']
        return render('/pay/index.mako')
