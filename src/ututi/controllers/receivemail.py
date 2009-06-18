from StringIO import StringIO
import logging
import mimetools
from routes.util import url_for
from nous.mailpost.MailBoxerTools import splitMail
from formencode import Schema, validators, Invalid, All

from pylons import request, response
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.mailer import raw_send_email
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
        attachments = []
        for md5, mimetype, filename in zip(md5_list,
                                           mime_type_list,
                                           file_name_list):
            f = File(filename,
                     filename,
                     mimetype=mimetype,
                     md5=md5)
            meta.Session.add(f)
            attachments.append(f)

        email = request.POST['Mail']
        msg = mimetools.Message(StringIO(email))
        headers, body = splitMail(email.encode("utf-8"))
        headers = "".join(msg.headers)
        all_emails = [email.email for email in
                      meta.Session.query(Email).filter_by(confirmed=False).all()]

        footer = ""
        for file in attachments:
            url = url_for(controller='files', action='get', id=file.id,
                          qualified=True)
            footer += '<a href="%s">%s</a>' % (url, file.title)
        new_message = "%s\r\n%s\r\n%s" % (headers, body, footer)
        raw_send_email(msg['From'], all_emails,  new_message)
        meta.Session.commit()
        return "Ok!"
