"""The base Controller API

Provides the BaseController class for subclassing.
"""
from datetime import datetime

from pylons.controllers import WSGIController
from pylons.templating import render_mako as render
from pylons import c

from ututi.lib import current_user
from ututi.model import meta


class BaseController(WSGIController):

    def __call__(self, environ, start_response):
        """Invoke the Controller"""
        # WSGIController.__call__ dispatches to the Controller method
        # the request is routed to. This routing information is
        # available in environ['pylons.routes_dict']

        c.user = current_user()

        # Record the time the user was last seen.
        if c.user is not None:
            c.user.last_seen = datetime.utcnow()
            meta.Session.commit()

        # Set the DB text search language
        meta.Session.execute("SET default_text_search_config = 'public.lt'");

        try:
            return WSGIController.__call__(self, environ, start_response)
        finally:
            meta.Session.remove()
