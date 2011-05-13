"""Routes configuration

The more specific and detailed routes should be defined first so they
may take precedent over the more generic routes. For more information
refer to the routes manual at http://routes.groovie.org/docs/
"""
from paste.util.converters import asbool
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
    /stats
    """
    always_scan = asbool(config.get('always_scan', False))
    map = Mapper(directory=config['pylons.paths']['controllers'],
                 always_scan=always_scan)
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
    map.connect('/contacts', controller='home', action='contacts')
    map.connect('/features', controller='home', action='features')
    map.connect('/advertising', controller='home', action='advertising')
    map.connect('/stats', controller='home', action='statistics')
    map.connect('/robots.txt', controller='home', action='robots')

    # essential ututi component routes go here

    map.connect('/group/{id}', controller='group', action='index')

    # Forum
    map.connect('/group/{id}/forum',
                controller='forum',
                action='categories')

    map.connect('/group/{id}/forum/new_category',
                controller='forum',
                action='new_category')

    map.connect('/group/{id}/forum/create_category',
                controller='forum',
                action='create_category')

    map.connect('/group/{id}/forum/{category_id}',
                controller='forum',
                action='index')

    map.connect('/group/{id}/forum/{category_id}/edit',
                controller='forum',
                action='edit_category')

    map.connect('/group/{id}/forum/{category_id}/delete',
                controller='forum',
                action='delete_category')

    map.connect('/group/{id}/forum/{category_id}/new_thread',
                controller='forum',
                action='new_thread')

    map.connect('/group/{id}/forum/{category_id}/mark_as_read',
                controller='forum',
                action='mark_category_as_read')

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

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/delete_post',
                controller='forum',
                action='delete_post')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/subscribe',
                controller='forum',
                action='subscribe')

    map.connect('/group/{id}/forum/{category_id}/thread/{thread_id}/unsubscribe',
                controller='forum',
                action='unsubscribe')

    # Mailing list
    map.connect('/group/{id}/mailinglist/{action}',
                controller='mailinglist')

    map.connect('/group/{id}/mailinglist/{action}/{thread_id}',
                controller='mailinglist')

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

    map.connect('/subject/*tags/{id}/notes/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/note/{page_id}',
                controller='subjectpage', action='index')

    map.connect('/subject/*tags/{id}/note/{page_id}/{action}',
                controller='subjectpage')

    map.connect('/subject/*tags/{id}/file/{file_id}/{action}',
                controller='subjectfile')

    subject_actions = ['feed', 'files', 'edit', 'watch', 'js_watch', 'update',
                       'delete', 'undelete', 'flag', 'create_folder', 'delete_folder',
                       'js_create_folder', 'js_delete_folder', 'upload_file',
                       'upload_file_short', 'teach', 'unteach', 'info']

    for action in subject_actions:
        map.connect('/subject/*tags/{id}/%s' % action,
                    controller='subject', action=action)

    map.connect('/subject/*tags/{id}/notes',
                controller='subject', action='pages')

    map.connect('/subject/*tags/{id}',
                controller='subject',
                action='home')

    # books
    map.connect('/books', controller='books', action='index')
    map.connect('/books/{id}/update', controller='books', action='update')
    map.connect('/books/{id}/logo/{width}/{height}',
                controller='books', action='logo')
    map.connect('/books/{id}/logo/{width}',
                controller='books', action='logo')
    map.connect('/books/catalog/{books_department}/location/{location_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/location/{location_id}/science/{science_type_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/science/{science_type_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/science/{science_type_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/{books_type_name}/science/{science_type_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/{books_type_name}/school_grade/{school_grade_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/{books_type_name}/location/{location_id}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}/{books_type_name}', controller="books", action="catalog")
    map.connect('/books/catalog/{books_department}', controller="books", action="catalog")

    # anonymous user logo actions
    map.connect('/user/logo/{width}/{height}',
                controller='anonymous',
                action='logo')
    map.connect('/user/logo/{width}',
                controller='anonymous',
                action='logo')

    # teacher profile pages
    map.connect('/teacher/{id}', controller='user', action='teacher_index')
    map.connect('/teacher/{id}/subjects', controller='user', action='teacher_subjects')
    map.connect('/teacher/{id}/biography', controller='user', action='teacher_biography')

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
    map.connect('/browse', controller='search', action='browse')
    map.connect('/home/feed', controller='profile', action='feed')
    map.connect('/home/start', controller='profile', action='get_started')
    map.connect('/home/subjects', controller='profile', action='my_subjects')

    #user registration path
    map.connect('/welcome', controller='profile', action='register_welcome')

    #new user registration path
    map.connect('/registration/resend', controller='registration', action='resend_code')
    map.connect('/registration/land_fb', controller='registration', action='land_fb')
    map.connect('/registration/confirm_fb', controller='registration', action='confirm_fb')
    map.connect('/registration/{hash}/confirm', controller='registration', action='confirm_email')
    map.connect('/registration/{hash}/university', controller='registration', action='university_info')
    map.connect('/registration/{hash}/university_create', controller='registration', action='university_create')
    map.connect('/registration/{hash}/personal_info', controller='registration', action='personal_info')
    map.connect('/registration/{hash}/add_photo', controller='registration', action='add_photo')
    map.connect('/registration/{hash}/link_google', controller='registration', action='link_google')
    map.connect('/registration/{hash}/unlink_google', controller='registration', action='unlink_google')
    map.connect('/registration/{hash}/link_facebook', controller='registration', action='link_facebook')
    map.connect('/registration/{hash}/unlink_facebook', controller='registration', action='unlink_facebook')
    map.connect('/registration/{hash}/google_verify', controller='registration', action='google_verify')
    map.connect('/registration/{hash}/invite_friends', controller='registration', action='invite_friends')
    map.connect('/registration/{hash}/invite_facebook_friends', controller='registration', action='invite_friends_fb')
    map.connect('/registration/{hash}/finish', controller='registration', action='finish')
    map.connect('/registration/logo/{id}/{size}', controller='registration', action='logo')

    map.connect('/profile/logo/{width}/{height}',
                controller='profile',
                action='logo')

    map.connect('/school/*path/update', controller='structureview', action='update')
    map.connect('/school/*path/login', controller='structureview', action='login')
    map.connect('/school/*path/edit', controller='structureview', action='edit')
    map.connect('/school/*path/catalog_js', controller='structureview', action='catalog_js')
    map.connect('/school/*path/feed', controller='structureview', action='feed')
    map.connect('/school/*path/groups', controller='structureview', action='catalog', obj_type='group')
    map.connect('/school/*path/subjects', controller='structureview', action='catalog', obj_type='subject')
    map.connect('/school/*path/teachers', controller='structureview', action='catalog', obj_type='teacher')
    map.connect('/school/*path/register', controller='structureview', action='register')
    map.connect('/school/*path/register/teacher', controller='structureview', action='register_teacher')
    map.connect('/school/*path/register/teacher/existing', controller='structureview', action='register_teacher_existing')
    map.connect('/school/*path', controller='structureview', action='index')

    # other user views
    map.connect('/invite_friends', controller='profile', action='invite_friends_fb')
    map.connect('/profile/confirm_emails', controller='profile', action='confirm_emails')
    map.connect('/confirm_user_email/{key}', controller='profile', action='confirm_user_email')
    map.connect('/profile/edit/contacts', controller='profile', action='edit_contacts')
    map.connect('/profile/edit/password', controller='profile', action='edit_password')
    map.connect('/profile/edit/wall', controller='profile', action='wall_settings')
    map.connect('/profile/edit/notifications', controller='profile', action='notifications')

    map.connect('/profile/{action}', controller='profile')
    map.connect('/profile/{action}/{id}', controller='profile')

    # wall actions
    map.connect('/wall/reply/mailinglist/{group_id}/{thread_id}',
                controller='wall', action='mailinglist_reply')
    map.connect('/wall/reply/forum/{group_id}/{category_id}/{thread_id}',
                controller='wall', action='forum_reply')
    map.connect('/wall/reply/privatemessage/{msg_id}',
                controller='wall', action='privatemessage_reply')
    map.connect('/wall/reply/comment/{event_id}',
                controller='wall', action='eventcomment_reply')
    map.connect('/wall/{action}', controller='wall')

    # CUSTOM ROUTES HERE
    map.connect('/sitemap.xml', controller='sitemap', action='index')
    map.connect('/channel.html', controller='home', action='fbchannel')
    map.connect('frontpage', '/', controller='home', action='index')
    map.connect('login', '/login', controller='home', action='login')
    map.connect('/logout', controller='home', action='logout')
    map.connect('/register', controller='home', action='register')
    map.connect('/google_login', controller='federation', action='google_login')
    map.connect('/google_verify', controller='federation', action='google_verify')
    map.connect('/facebook_login', controller='federation', action='facebook_login')
    map.connect('/password', controller='home', action='pswrecovery')
    map.connect('/process_transaction', controller='home', action='process_transaction')
    map.connect('/recovery/{key}', controller='home', action='recovery')
    map.connect('/recovery', controller='home', action='recovery')
    map.connect('/tour', controller='home', action='tour')

    map.connect('/got_mail', controller='receivemail', action='index')
    map.connect('/admin', controller='admin', action='index')
    map.connect('/admin/example_blocks', controller='admin', action='example_blocks')

    map.connect('/admin/teacher_status/{command}/{id}', controller='admin', action='teacher_status')
    map.connect('/admin/edit_i18n_text/{id}/{lang}', controller='admin', action='edit_i18n_text')
    map.connect('/admin/{action}/{id}', controller='admin')
    map.connect('/admin/{action}', controller='admin')

    map.connect('/structure/completions/{text}', controller='structure', action='completions')
    map.connect('/structure', controller='structure', action='index')
    map.connect('export_university', '/structure/{university_id}/export',
                controller='admin', action='export_university')
    map.connect('/structure/{id}/logo/{width}/{height}',
                controller='structure', action='logo')
    map.connect('/structure/{id}/logo/{width}',
                controller='structure', action='logo')

    map.connect('/community',
                controller='community', action='index', id=None, category_id=1)
    map.connect('/community/{action}',
                controller='community', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}',
                controller='community', action='thread', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/reply',
                controller='community', action='reply', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/edit',
                controller='community', action='edit', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/edit_post',
                controller='community', action='edit_post', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/delete_post',
                controller='community', action='delete_post', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/subscribe',
                controller='community', action='subscribe', id=None, category_id=1)
    map.connect('/community/thread/{thread_id}/unsubscribe',
                controller='community', action='unsubscribe', id=None, category_id=1)

    map.connect('/bugs',
                controller='bugs', action='index', id=None, category_id=2)
    map.connect('/bugs/{action}',
                controller='bugs', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}',
                controller='bugs', action='thread', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/reply',
                controller='bugs', action='reply', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/edit',
                controller='bugs', action='edit', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/edit_post',
                controller='bugs', action='edit_post', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/delete_post',
                controller='bugs', action='delete_post', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/subscribe',
                controller='bugs', action='subscribe', id=None, category_id=2)
    map.connect('/bugs/thread/{thread_id}/unsubscribe',
                controller='bugs', action='unsubscribe', id=None, category_id=2)

    map.connect('switch_language', '/switch_language', controller='home', action='switch_language')

    map.connect('/{controller}', action='index')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/{id}')
    return map
