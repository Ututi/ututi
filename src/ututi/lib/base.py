"""The base Controller API

Provides the BaseController class for subclassing.
"""
import re
import logging
import time
from datetime import datetime

from sqlalchemy.exc import InternalError
from sqlalchemy.exc import InvalidRequestError

from mako.exceptions import TopLevelLookupException

from paste.util.converters import asbool
from pylons.decorators.cache import beaker_cache
from pylons.controllers import WSGIController
from pylons.templating import pylons_globals, render_mako, render_mako_def
from pylons import url, session
from pylons import tmpl_context as c, config, request, response
from pylons.i18n.translation import set_lang

from ututi.lib.cache import u_cache # reexport
from ututi.lib.security import current_user, sign_in_user
from ututi.lib.geoip import get_geolocation
from ututi.model import meta

perflog = logging.getLogger('performance')

def render(*args, **kwargs):
    from ututi.views import render_view
    kwargs.setdefault('extra_vars', {})
    if kwargs['extra_vars'] is None:
        kwargs['extra_vars'] = {}
    kwargs['extra_vars']['v'] = render_view
    return render_mako(*args, **kwargs)

def render_def(*args, **kwargs):
    from ututi.views import render_view
    kwargs['v'] = render_view
    return render_mako_def(*args, **kwargs)

class BaseController(WSGIController):

    def __call__(self, environ, start_response):
        """Invoke the Controller"""
        # WSGIController.__call__ dispatches to the Controller method
        # the request is routed to. This routing information is
        # available in environ['pylons.routes_dict']

        # Global variables
        # XXX reduce the scope of most of them
        c.breadcrumbs = None
        c.object_location = None
        c.hash = None
        c.email = None
        c.serve_file = None
        c.security_context = None
        c.obj_type = None
        c.results = None
        c.step = None
        c.searched = None
        c.slideshow = None
        c.structure = None
        c.login_form_url = None
        c.final_msg = None
        c.message_class = None
        c.text = None
        c.tags = None
        c.pylons_config = config

        c.fb_random_post = None

        c.testing = asbool(config.get('testing', False))
        c.gg_enabled = asbool(config.get('gg_enabled', False))
        c.tpl_lang = config.get('tpl_lang', 'en')
        c.mailing_list_host = config.get('mailing_list_host', '')
        c.google_tracker = config['google_tracker']
        c.facebook_app_id = config.get('facebook.appid')
        config.get('facebook.appid')

        c.redirect_to = request.params.get('redirect_to', '')
        c.came_from = request.params.get('came_from', '')
        c.came_from_search = False #if the user came from google search

        lang = session.get('language', None)
        if not lang:
            lang = get_geolocation() or 'en'
        set_lang(lang)
        c.lang = lang
        # XXX get these from db
        c.timezone = 'UTC'
        c.locale = 'en'

        succeeded = False
        try:
            # Record the time the user was last seen.
            c.user = current_user()
            if c.user is not None:
                environ['repoze.who.identity'] = c.user.id
                from ututi.model import User
                meta.Session.query(User).filter_by(id=c.user.id).with_lockmode('update').one()
                c.user.last_seen = datetime.utcnow()
                meta.Session.commit()
                user_email = c.user.emails[0].email
            else:
                #the user is anonymous - check if he is coming from google search
                referrer = request.headers.get('referer', '')
                r = re.compile('www\.google\.[a-zA-Z]{2,4}/[url|search]')
                if r.search(referrer) is not None:
                    response.set_cookie('camefromsearch', 'yes', max_age=3600)
                    c.came_from_search = True
                else:
                    c.came_from_search = request.cookies.get('camefromsearch', None) == 'yes'
                user_email = 'ANONYMOUS'

            from ututi.model import Notification
            #find notification for the user
            c.user_notification = None
            if c.user is not None:
                  c.user_notification = Notification.unseen_user_notification(c.user)
            succeeded = True
        finally:
            if not succeeded:
                meta.Session.remove()

        request_start_walltime = time.time()
        request_start_cputime = time.clock()

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

            # Performance logging.
            perflog.log(logging.INFO,
                'request %(controller)s.%(action)s %(duration).4f %(duration_cpu).4f %(user_email)s'
                 % dict(controller=environ['pylons.routes_dict'].get('controller'),
                        action=environ['pylons.routes_dict'].get('action'),
                        duration=time.time() - request_start_walltime,
                        duration_cpu=time.clock() - request_start_cputime,
                        user_email=user_email))
