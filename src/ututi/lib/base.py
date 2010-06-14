"""The base Controller API

Provides the BaseController class for subclassing.
"""
import re
from datetime import datetime

from sqlalchemy.exc import InternalError
from sqlalchemy.exc import InvalidRequestError

from mako.exceptions import TopLevelLookupException

from paste.util.converters import asbool
from pylons.decorators.cache import beaker_cache
from pylons.controllers import WSGIController
from pylons.templating import pylons_globals, render_mako as render
from pylons import tmpl_context as c, config, request, response
from pylons.i18n.translation import get_lang

from ututi.lib.security import current_user
from ututi.model import meta


def u_cache(**kwargs):
    kwargs['cache_response'] = False
    return beaker_cache(**kwargs)


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
        c.blog_entries = None
        c.results = None
        c.step = None
        c.searched = None
        c.slideshow = None
        c.structure = None
        c.login_form_url = None
        c.final_msg = None
        c.message_class = None
        c.show_login = None
        c.text = None
        c.tags = None
        c.login_error = None
        c.new_design = False

        c.user = current_user()
        c.testing = asbool(config.get('testing', False))
        c.gg_enabled = asbool(config.get('gg_enabled', False))
        c.tpl_lang = config.get('tpl_lang', 'en')
        c.mailing_list_host = config.get('mailing_list_host', '')
        c.google_tracker = config['google_tracker']

        c.came_from = request.params.get('came_from', '')
        c.came_from_search = False #if the user came from google search

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
        else:
            #the user is anonymous - check if he is coming from google search
            referrer = request.headers.get('referer', '')
            r = re.compile('www\.google\.[a-zA-Z]{2,4}/[url|search]')
            if r.search(referrer) is not None:
                response.set_cookie('camefromsearch', 'yes', expires=3600)
                c.came_from_search = True
            else:
                c.came_from_search = request.cookies.get('camefromsearch', None) == 'yes'

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

def render_lang(template_name, extra_vars=None, cache_key=None,
                cache_type=None, cache_expire=None):
    """
    Render a template depending on its language. What this does is it tries 3 alternatives.
    Assuming the template name specified is template.mako, this function will try to render (in that order):
    template/[current_lang].mako
    template/[default_lang].mako (now it is lt.mako, hardcoded)
    template.mako
    """
    glob = pylons_globals()
    template_base = template_name[:-5] #remove the mako ending

    lang = c.tpl_lang #template selection language separated from the interface language

    templates = [
        '/'.join([template_base, '%s.mako' % lang]), #active language
        '/'.join([template_base, 'lt.mako']), #default lang
        template_name]

    templates = reversed(list(enumerate(reversed(templates))))
    #needed to reverse-enumerate, found no better way
    #(2, template1), (1, template2), (0, template3)

    for n, template in templates:
        try:
            return render(template, extra_vars, cache_key, cache_type, cache_expire)
        except TopLevelLookupException:
            if n > 0:
                pass
            else:
                raise #raise an exception if it's the last template in the list
