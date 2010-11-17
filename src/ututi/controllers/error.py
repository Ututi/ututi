from pylons import request, tmpl_context as c
import ututi.lib.helpers as h

from ututi.model import get_supporters
from ututi.lib.base import render
from ututi.lib.mailer import send_email

from pylons.i18n import _
from pylons import url, config

from pylons.controllers.util import redirect

from ututi.controllers.search import SearchController
class ErrorController(SearchController):
    """Generates error documents as and when they are required.

    The ErrorDocuments middleware forwards to ErrorController when error
    related status codes are returned from the application.

    This behaviour can be altered by changing the parameters to the
    ErrorDocuments middleware in your config/middleware.py file.

    """

    def document(self):
        c.ututi_supporters = get_supporters()
        resp = request.environ.get('pylons.original_response')
        req = request.environ.get('pylons.original_request')
        if resp is None:
            return render("/error.mako")

        c.reason = req.environ.get('ututi.access_denied_reason', None)
        if resp.status_int == 403:
            return render("/access_denied.mako")
        elif resp.status_int == 404:
            h.flash(_("Document at %(url)s was not found, but maybe you are interested in something else?") % {
                    'url': req.url.encode('ascii', 'ignore')})
            self.form_result = {}
            self._search()
            return render('/search/index.mako')

        return render("/error.mako")

    def send_error(self):
        if request.method == 'POST':
            sender = config.get('ututi_emails_from', 'info@ututi.lt')
            action = request.POST.get('submit')
            message = ""
            if c.user:
                sender = c.user.emails[0].email
            if action == "shout":
                h.flash(_('Monkeys are ashamed of what you said and are now working even harder to fix the problem. Until they do that, try to search for something else.'))
                message = request.POST.get('error_message')
            elif action == "kick":
                message = _("User kicked monkeys")
                h.flash(_('Ouch! Monkeys were kicked and are trying to work harder.  Until they fix this, try to search for something else.'))
            send_email(sender, config.get('error_email', 'errors@ututi.lt'), "["+_("Error message")+"]", message)
        redirect(url(controller='search', action="index"))
