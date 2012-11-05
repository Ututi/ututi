from pylons import request, tmpl_context as c
import ututi.lib.helpers as h

from ututi.lib.base import render
from ututi.lib.mailer import send_email

from pylons.i18n import _
from pylons import url, config, session

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
        resp = request.environ.get('pylons.original_response')
        req = request.environ.get('pylons.original_request')
        c.came_from = url.current()
        if resp is None:
            return render("/error.mako")

        c.reason = req.environ.get('ututi.access_denied_reason', None)
        if resp.status_int in [403, 404]:
            self.form_result = {}
            self._search()
            c.came_from = url('/')
            if resp.status_int == 403:
                return render("/access_denied.mako")

            elif resp.status_int == 404:
                h.flash(_("Document at %(url)s was not found, but maybe you are interested in something else?") % {
                        'url': req.url.encode('ascii', 'ignore')})

                # if user is logged in, show search form, otherwise - login form
                try:
                    if session['login']:
                        return render('/search/index.mako')
                except KeyError:
                    return render('/login.mako')

        return render("/error.mako")

    def send_error(self):
        if request.method == 'POST':
            sender = config.get('ututi_emails_from', 'info@ututi.lt')
            action = request.POST.get('submit')
            user_shout = request.POST.get('error_message')
            message = ""
            if c.user:
                sender = c.user.emails[0].email
            if action == "shout":
                h.flash(_('Monkeys are ashamed of what you said and are now working even harder to fix the problem. Until they do that, try to search for something else.'))
                message = user_shout
            elif action == "kick":
                message = '%s\n\n%s' % (_("User kicked monkeys"), user_shout)
                h.flash(_('Ouch! Monkeys were kicked and are trying to work harder.  Until they fix this, try to search for something else.'))
            send_email(sender, config.get('error_email', 'errors@ututi.lt'), "["+_("Error message")+"]", message)
        redirect(url(controller='search', action="index"))
