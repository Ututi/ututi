import logging
from formencode import Schema, validators, Invalid, All

from pylons import request, response
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request
from ututi.model import meta, User, Email

log = logging.getLogger(__name__)


class ReceivemailController(BaseController):

     def index(self):
         log.info(request.GET)
         log.info(request.POST)
         return str(request.POST)
