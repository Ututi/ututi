"""Routes configuration

The more specific and detailed routes should be defined first so they
may take precedent over the more generic routes. For more information
refer to the routes manual at http://routes.groovie.org/docs/
"""
from routes import Mapper


def make_map(config):
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
    /advertising
    /statistics
    """

    map = Mapper(directory=config['pylons.paths']['controllers'],
                 always_scan=config['debug'])
    map.minimization = False

    map.redirect('/*path/?*get', '/{path}?{get}', _redirect_code='301 Moved Permanently')
    map.redirect('/*path/', '/{path}', _redirect_code='301 Moved Permanently')

    # The ErrorController route (handles 404/500 error pages); it should
    # likely stay at the top, ensuring it can always be resolved
    map.connect('/error/{action}', controller='error')
    map.connect('/error/{action}/{id}', controller='error')

    # static terms and about pages
    map.connect('/bunners', controller='home', action='banners')
    map.connect('/terms', controller='home', action='terms')
    map.connect('/about', controller='home', action='about')
    map.connect('/advertising', controller='home', action='advertising')
    map.connect('/statistics', controller='home', action='statistics')
    map.connect('/robots.txt', controller='home', action='robots')

    # essential ututi component routes go here

    map.connect('/group/{id}', controller='group', action='index')

    # Forum
    map.connect('/group/{id}/forum/create',
                controller='forum',
                action='create')

    map.connect('/group/{id}/forum',
                controller='forum',
                action='list')

    map.connect('/group/{id}/forum/{category_id}',
                controller='forum',
                action='index')

    map.connect('/group/{id}/forum/{category_id}/new_thread',
                controller='forum',
                action='new_thread')

    map.connect('/group/{id}/forum/{category_id}/post',
                controller='forum',
                action='post')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}',
                controller='forum',
                action='thread')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/reply',
                controller='forum',
                action='reply')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/edit',
                controller='forum',
                action='edit')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/edit_post',
                controller='forum',
                action='edit_post')

    # Mailing list
    map.connect('/group/{id}/mailinglist',
                controller='mailinglist',
                action='index')

    map.connect('/group/{id}/mailinglist/{action}',
                controller='mailinglist')

    map.connect('/group/{id}/mailinglist/thread/{thread_id}',
                controller='mailinglist',
                action='thread')

    map.connect('/group/{id}/mailinglist/thread/{thread_id}/reply',
                controller='mailinglist',
                action='reply')

    map.connect('/group/{id}/mailinglist/file/{message_id}/{file_id}',
                controller='mailinglist',
                action='file')

    map.connect('/group/{id}/file/{file_id}/{action}',
                controller='groupfile')

    # Backwards compatibility.
    map.connect('/group/{id}/forum/thread/{thread_id}',
                controller='forum',
                action='legacy_thread')

    map.connect('/group/{id}/forum/thread/{thread_id}/reply',
                controller='forum',
                action='legacy_reply')

    map.connect('/group/{id}/forum/file/{message_id}/{file_id}',
                controller='forum',
                action='legacy_file')

    #act on group membership request
    map.connect('/group/{id}/request/{hash_code}/{do}', controller='group', action='request')

    map.connect('/group/{id}/{action}', controller='group')
    map.connect('/group/{id}/logo/{width}/{height}', controller='group', action='logo')
    map.connect('/group/{id}/logo/{width}', controller='group', action='logo')
    map.connect('/groups/{action}', controller='group')

    map.connect('/subjects/{action}', controller='subject')

    map.connect('/subject/*tags/{id}/pages/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/page/{page_id}',
                controller='subjectpage', action='index')

    map.connect('/subject/*tags/{id}/page/{page_id}/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/file/{file_id}/{action}',
                controller='subjectfile')

    subject_actions = ['edit', 'watch', 'js_watch', 'update', 'delete',
                       'undelete', 'create_folder', 'delete_folder',
                       'js_create_folder', 'js_delete_folder', 'upload_file',
                       'upload_file_short']

    for action in subject_actions:
        map.connect('/subject/*tags/{id}/%s' % action,
                    controller='subject', action=action)

    map.connect('/subject/*tags/{id}',
                controller='subject',
                action='home')

    # user profiles
    map.connect('/user/{id}', controller='user', action='index')
    map.connect('/user/{id}/{action}', controller='user')
    map.connect('/user/{id}/logo/{width}/{height}',
                controller='user',
                action='logo')
    map.connect('/user/{id}/logo/{width}',
                controller='user',
                action='logo')

    # user's information
    map.connect('/home', controller='profile', action='home')
    map.connect('/home/feed', controller='profile', action='feed')

    #user registration path
    map.connect('/welcome', controller='profile', action='welcome')
    map.connect('/register/welcome', controller='profile', action='register_welcome')
    map.connect('/findgroup', controller='profile', action='findgroup')

    map.connect('/profile/logo/{width}/{height}',
                controller='profile',
                action='logo')

    map.connect('/school/*path/update', controller='structureview', action='update')
    map.connect('/school/*path/edit', controller='structureview', action='edit')
    map.connect('/school/*path/search_js', controller='structureview', action='search_js')
    map.connect('/school/*path', controller='structureview', action='index')

    # other user views
    map.connect('/profile/confirm_emails', controller='profile', action='confirm_emails')
    map.connect('/confirm_user_email/{key}', controller='profile', action='confirm_user_email')
    map.connect('/profile', controller='profile', action='index')
    map.connect('/profile/{action}', controller='profile')

    # CUSTOM ROUTES HERE
    map.connect('/sitemap.xml', controller='sitemap', action='index')
    map.connect('/', controller='home', action='index')
    map.connect('/login', controller='home', action='login')
    map.connect('/logout', controller='home', action='logout')
    map.connect('/join', controller='home', action='join')
    map.connect('/join/login', controller='home', action='join_login')
    map.connect('/join/login_register', controller='home', action='join_register')
    map.connect('/register', controller='home', action='register')
    map.connect('/password', controller='home', action='pswrecovery')
    map.connect('/process_transaction', controller='home', action='process_transaction')
    map.connect('/recovery/{key}', controller='home', action='recovery')
    map.connect('/recovery', controller='home', action='recovery')
    map.connect('/register/{hash}', controller='home', action='register')
    map.connect('/tour', controller='home', action='tour')

    map.connect('/got_mail', controller='receivemail', action='index')
    map.connect('/admin', controller='admin', action='index')

    map.connect('/admin/blog', controller='blog', action='index')
    map.connect('/admin/blog/{action}', controller='blog')
    map.connect('/admin/blog/{action}/{id}', controller='blog', action='edit')


    map.connect('/structure/completions/{text}', controller='structure', action='completions')
    map.connect('/structure', controller='structure', action='index')
    map.connect('/structure/{id}/logo/{width}/{height}',
                controller='structure', action='logo')
    map.connect('/structure/{id}/logo/{width}',
                controller='structure', action='logo')

    map.connect('forum_community_index', '/community',
                controller='publicforum', action='index', id=None, category_id=1)
    map.connect('/community/{action}',
                controller='publicforum', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}',
                controller='publicforum', id=None, category_id=1, action='thread')
    map.connect('/community/thread/{thread_id}/reply',
                controller='publicforum', id=None, category_id=1, action='reply')
    map.connect('/community/thread/{thread_id}/edit',
                controller='publicforum', id=None, category_id=1, action='edit')
    map.connect('/community/thread/{thread_id}/edit_post',
                controller='publicforum', id=None, category_id=1, action='edit_post')

    map.connect('forum_bugs_index', '/bugs',
                controller='publicforum', action='index', id=None, category_id=2)
    map.connect('/bugs/{action}',
                controller='publicforum', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}',
                controller='publicforum', id=None, category_id=2, action='thread')
    map.connect('/bugs/thread/{thread_id}/reply',
                controller='publicforum', id=None, category_id=2, action='reply')
    map.connect('/bugs/thread/{thread_id}/edit',
                controller='publicforum', id=None, category_id=2, action='edit')
    map.connect('/bugs/thread/{thread_id}/edit_post',
                controller='publicforum', id=None, category_id=2, action='edit_post')

    map.connect('/{controller}', action='index')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/{id}')

    return map
