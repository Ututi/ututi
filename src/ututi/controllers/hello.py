import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort, redirect_to
from pylons.i18n import get_lang, set_lang, _
from zope.interface import Interface
import grokcore.component

from ututi.lib.base import BaseController, render

log = logging.getLogger(__name__)


class IMyGlobalUtility(Interface):
    pass


class MyGlobalUtility(grokcore.component.GlobalUtility):
    grokcore.component.implements(IMyGlobalUtility)

    @property
    def title(self):
        return "OMG it works!"


class HelloController(BaseController):

    def index(self):
        from zope.component import getUtility
        c.title = getUtility(IMyGlobalUtility).title
        return render('/hello.mako')
