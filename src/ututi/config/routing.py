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

    map.connect('/group/{id}/forum',
                controller='groupforum',
                action='index')

    map.connect('/group/{id}/forum/{action}',
                controller='groupforum')

    map.connect('/group/{id}/forum/thread/{thread_id}',
                controller='groupforum',
                action='thread')

    map.connect('/group/{id}/forum/thread/{thread_id}/reply',
                controller='groupforum',
                action='reply')

    map.connect('/group/{id}/{action}', controller='group')
    map.connect('/group/{id}/logo/{width}/{height}', controller='group', action='logo')
    map.connect('/group/{id}/logo/{width}', controller='group', action='logo')
    map.connect('/groups', controller='group', action='index')
    map.connect('/groups/{action}', controller='group')

    map.connect('/subjects', controller='subject', action='index')
    map.connect('/subjects/{action}', controller='subject')

    map.connect('/subject/*tags/{id}/pages/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/page/{page_id}',
                controller='subjectpage', action='index')

    map.connect('/subject/*tags/{id}/page/{page_id}/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/edit',
                controller='subject', action='edit')

    map.connect('/subject/*tags/{id}/update',
                controller='subject', action='update')

    map.connect('/subject/*tags/{id}/create_folder',
                controller='subject', action='create_folder')

    map.connect('/subject/*tags/{id}/delete_folder',
                controller='subject', action='delete_folder')

    map.connect('/subject/*tags/{id}/upload_file',
                controller='subject', action='upload_file')

    map.connect('/subject/*tags/{id}',
                controller='subject',
                action='home')

    #user profiles
    map.connect('/user/{id}', controller='user', action='index')
    map.connect('/user/{id}/{action}', controller='user')
    map.connect('/user/{id}/logo/{width}/{height}',
                controller='user',
                action='logo')
    map.connect('/user/{id}/logo/{width}',
                controller='user',
                action='logo')

    #user's information
    map.connect('/home', controller='profile', action='home')
    map.connect('/profile', controller='profile', action='index')
    map.connect('/profile/{action}', controller='profile')
    map.connect('/confirm_emails', controller='profile', action='confirm_emails')
    map.connect('/confirm_user_email/{key}', controller='profile', action='confirm_user_email')

    #user registration path
    map.connect('/welcome', controller='home', action='welcome')
    map.connect('/findgroup', controller='home', action='findgroup')

    # CUSTOM ROUTES HERE
    map.connect('/', controller='home')
    map.connect('/register', controller='home', action='register')

    map.connect('/got_mail', controller='receivemail', action='index')
    map.connect('/admin', controller='admin', action='index')
    map.connect('/structure/completions/{text}', controller='structure', action='completions')
    map.connect('/structure', controller='structure', action='index')
    map.connect('/structure/{id}/logo/{width}/{height}',
                controller='structure', action='logo')
    map.connect('/files', controller='files', action='index')

    map.connect('/{controller}', action='index')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/{id}')

    return map
