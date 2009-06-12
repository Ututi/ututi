"""Routes configuration

The more specific and detailed routes should be defined first so they
may take precedent over the more generic routes. For more information
refer to the routes manual at http://routes.groovie.org/docs/
"""
from pylons import config
from routes import Mapper

def make_map():
    """Create, configure and return the routes Mapper"""
    map = Mapper(directory=config['pylons.paths']['controllers'],
                 always_scan=config['debug'])
    map.minimization = False

    # The ErrorController route (handles 404/500 error pages); it should
    # likely stay at the top, ensuring it can always be resolved
    map.connect('/error/{action}', controller='error')
    map.connect('/error/{action}/{id}', controller='error')

    # CUSTOM ROUTES HERE
    map.connect('/', controller='home')
    map.connect('/register', controller='home', action='register')
    map.connect('/profile', controller='user')
    map.connect('/admin', controller='admin', action='index')
    map.connect('/structure', controller='structure', action='index')
    map.connect('/confirm_emails', controller='user', action='confirm_emails')
    map.connect('/confirm_user_email/{key}', controller='user', action='confirm_user_email')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/{id}')

    return map
