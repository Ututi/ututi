from pylons import request

from ututi.lib.base import BaseController, render


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
        if resp is None:
            return render("/error.mako")

        if resp.status_int == 403:
            return render("/access_denied.mako")
        elif resp.status_int == 404:
            from ututi.lib import helpers as h
            from pylons.i18n import _
            h.flash(_("Document at %(url)s was not found, but maybe you are interested in something else?") % {
                    'url': req.url.encode('ascii', 'ignore')})
            self.form_result = {}
            self._search()
            return render('/search/index.mako')

        return render("/error.mako")
