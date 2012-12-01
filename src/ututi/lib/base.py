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
from ututi.lib.geoip import get_country_code
from ututi.model import meta

perflog = logging.getLogger('performance')

def render(*args, **kwargs):
    kwargs.setdefault('extra_vars', {})
    if kwargs['extra_vars'] is None:
        kwargs['extra_vars'] = {}
    return render_mako(*args, **kwargs)

def render_def(*args, **kwargs):
    return render_mako_def(*args, **kwargs)


def get_mem_usage():
    return int(open('/proc/self/stat').read().split()[22])


class BaseController(WSGIController):

    def __call__(self, environ, start_response):
        """Invoke the Controller"""
        # WSGIController.__call__ dispatches to the Controller method
        # the request is routed to. This routing information is
        # available in environ['pylons.routes_dict']

        request_start_memory_usage = get_mem_usage()
        if 'HTTP_X_FORWARDED_SCHEME' in environ:
            environ['wsgi.url_scheme'] = environ.pop('HTTP_X_FORWARDED_SCHEME')

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
        c.theme = None
        c.pylons_config = config

        c.testing = asbool(config.get('testing', False))
        c.mailing_list_host = config.get('mailing_list_host', '')
        c.google_tracker = config.get('google_tracker', '')
        c.facebook_app_id = config.get('facebook.appid')
        config.get('facebook.appid')
        c.redirect_to = request.params.get('redirect_to', '')
        c.came_from = request.params.get('came_from', '')
        c.came_from_search = False #if the user came from google search

        lang = session.get('language', None)
        if not lang:
            lang = get_country_code() or 'en'
            if lang not in ['lt', 'pl', 'en']:
                lang = 'en'
        session['language'] = lang
        session.save()
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
                user_email = c.user.email.email
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

        if c.user is not None:
            c.theme = c.user.location.get_theme()

        self._push_custom_urls()

        request_start_walltime = time.time()
        request_start_cputime = time.clock()

        try:
            return WSGIController.__call__(self, environ, start_response)
        finally:
            meta.Session.remove()
            self._pop_custom_urls()

            # Performance logging.
            perflog.log(logging.INFO,
                'request\t%(controller)s.%(action)s\t%(duration).4f\t%(duration_cpu).4f\t%(memory_usage)d\t%(user_email)s'
                 % dict(controller=environ['pylons.routes_dict'].get('controller'),
                        action=environ['pylons.routes_dict'].get('action'),
                        duration=time.time() - request_start_walltime,
                        duration_cpu=time.clock() - request_start_cputime,
                        memory_usage=get_mem_usage() - request_start_memory_usage,
                        user_email=user_email))

    def _push_custom_urls(self):
        """
        Push custom URL function to generate proper URLs for
        external pages (i.e. http://mif.vu.lt/ututi/teachers)
        as well as internal pages (i.e. http://ututi.com/about.

        We use absolute URLs, otherwise pylons redirect() makes
        up wrong URLs (it does not use url function).

        Example configuration for external server:

        RewriteRule ^/ututi(/(.*))?$ http://ututi.com/school/uni$2 [P,L]
        RequestHeader add X-Vhm-Root mif.vu.lt
        RequestHeader add X-Vhm-Root-Dir /ututi
        RequestHeader add X-Vhm-Host-Dir /school/uni
        """

        if hasattr(self, '_pushed_url_object'):
            return

        ututi_host = request.headers.get('Host')
        ututi_dir = request.headers.get('X-Vhm-Host-Dir')
        external_host = request.headers.get('X-Vhm-Root')
        external_dir = request.headers.get('X-Vhm-Root-Dir', '')

        if ututi_dir:
            orig_url = url._current_obj()

            def new_url(*args, **kwargs):
                urlstring = orig_url(*args, **kwargs)
                kwargs['qualified'] = True
                if urlstring.startswith(ututi_dir):
                    kwargs['host'] = external_host
                    return orig_url(*args, **kwargs)\
                            .replace(ututi_dir, external_dir, 1)
                else:
                    kwargs['host'] = ututi_host
                    return orig_url(*args, **kwargs)

            def current_url_proxy(*args, **kwargs):
                # TODO: reimplement the same logic as in new_url,
                # so we don't depend on internal _use_current parameter.
                kwargs['_use_current'] = True
                return new_url(*args, **kwargs)

            new_url.current = current_url_proxy
            url._push_object(new_url)
            self._pushed_url_object = new_url

    def _pop_custom_urls(self):
        if hasattr(self, '_pushed_url_object'):
            url._pop_object(self._pushed_url_object)
            delattr(self, '_pushed_url_object')

