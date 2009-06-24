"""Routes configuration

The more specific and detailed routes should be defined first so they
may take precedent over the more generic routes. For more information
refer to the routes manual at http://routes.groovie.org/docs/
"""
from pylons import config
from routes import Mapper

def make_map():
    """Create, configure and return the routes Mapper

    Planned routes:

    /group/add
    /group/{group_id}/[files|pages|forum|admin|subjects]
    /group/{group_id}/subjects/add_subject

    /subject/add
    /subject/{l1}/{l2}/{l3}/{pretty_name}/[files|pages|QA|edit]

    /profile/edit
    /profile/{user_id}
    /profile/{pretty_name}
    /register
    /home
    /search

    """

    map = Mapper(directory=config['pylons.paths']['controllers'],
                 always_scan=config['debug'])
    map.minimization = False

    # The ErrorController route (handles 404/500 error pages); it should
    # likely stay at the top, ensuring it can always be resolved
    map.connect('/error/{action}', controller='error')
    map.connect('/error/{action}/{id}', controller='error')

    # essential ututi component routes go here

    map.connect('/group/{id}', controller='group', action='group_home')
    map.connect('/group/{id}/{action}', controller='group')
    map.connect('/groups', controller='group', action='index')
    map.connect('/groups/{action}', controller='group')

    map.connect('/subject', controller='subject', action='index')
    map.connect('/subject/{id}', controller='subject', action='subject_home')

    # CUSTOM ROUTES HERE
    map.connect('/', controller='home')
    map.connect('/home', controller='home', action='home')
    map.connect('/register', controller='home', action='register')
    map.connect('/profile', controller='user')
    map.connect('/got_mail', controller='receivemail', action='index')
    map.connect('/admin', controller='admin', action='index')
    map.connect('/structure', controller='structure', action='index')
    map.connect('/files', controller='files', action='index')
    map.connect('/confirm_emails', controller='user', action='confirm_emails')
    map.connect('/confirm_user_email/{key}', controller='user', action='confirm_user_email')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/{id}')

    return map
