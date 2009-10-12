"""The base Controller API

Provides the BaseController class for subclassing.
"""
from datetime import datetime

from sqlalchemy.exc import InternalError
from sqlalchemy.exc import InvalidRequestError

from pylons.controllers import WSGIController
from pylons.templating import render_mako as render
from pylons import c, config
from pylons.i18n.translation import get_lang

from ututi.lib.security import current_user
from ututi.model import meta


class BaseController(WSGIController):

    def __call__(self, environ, start_response):
        """Invoke the Controller"""
        # WSGIController.__call__ dispatches to the Controller method
        # the request is routed to. This routing information is
        # available in environ['pylons.routes_dict']

        c.user = current_user()
        c.google_tracker = config['google_tracker']

        lang = get_lang()
        if not lang:
            c.lang = 'lt'
        else:
            c.lang = lang[0]

        # Record the time the user was last seen.
        if c.user is not None:
            environ['repoze.who.identity'] = c.user.id
            c.user.last_seen = datetime.utcnow()
            meta.Session.commit()

        try:
            return WSGIController.__call__(self, environ, start_response)
        finally:
            try:
                meta.Session.execute("SET ututi.active_user TO 0")
            except (InvalidRequestError, InternalError):
                # Ignore the error, if we got an error in the
                # controller this call raises an error
                pass
            meta.Session.remove()
