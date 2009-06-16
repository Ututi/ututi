import logging
from formencode import Schema, validators, Invalid, All

from pylons import request, response
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request
from ututi.model import File
from ututi.model import meta, User, Email

log = logging.getLogger(__name__)


class ReceivemailController(BaseController):

    def index(self):
        md5_list = request.POST.getall("md5[]")
        mime_type_list = request.POST.getall("mime-type[]")
        file_name_list = request.POST.getall("filename[]")
        for md5, mimetype, filename in zip(md5_list,
                                           mime_type_list,
                                           file_name_list):
            f = File(filename,
                     filename,
                     mimetype=mimetype,
                     md5=md5)
            meta.Session.add(f)
        meta.Session.commit()
        return "Ok!"
