"""The base Controller API

Provides the BaseController class for subclassing.
"""
from datetime import datetime

from sqlalchemy.exc import InternalError
from sqlalchemy.exc import InvalidRequestError

from mako.exceptions import TopLevelLookupException

from paste.util.converters import asbool
from pylons.controllers import WSGIController
from pylons.templating import pylons_globals, render_mako as render
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
        c.testing = asbool(config.get('testing', False))
        c.gg_enabled = asbool(config.get('gg_enabled', False))
        c.tpl_lang = config.get('tpl_lang', 'en')
        c.mailing_list_host = config.get('mailing_list_host', '')

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
