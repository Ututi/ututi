import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort, redirect_to
from pylons.i18n import get_lang, set_lang, _

from ututi.lib.base import BaseController, render

log = logging.getLogger(__name__)


class HomeController(BaseController):

    def index(self):
        return render('/index.mako')

    def login(self):
        return render('/index.mako')
