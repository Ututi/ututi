import re
from random import Random
import string

from pylons import response, url, request, session, tmpl_context as c, config
from pylons.controllers.util import abort
from pylons.controllers.util import redirect

from repoze.what.predicates import NotAuthorizedError
from repoze.what.plugins.pylonshq.protectors import ActionProtector as BaseActionProtector

from ututi.lib.geoip import set_geolocation

def current_user():
    from ututi.model import User
    try:
        login = session.get('login', None)
        if login is None:
            return None
        login = int(login)
    except ValueError:
        return None

    session_secret = session.get('cookie_secret', None)
    cookie_secret = request.cookies.get('ututi_session_lifetime', None)

    if session_secret != cookie_secret:
        session.delete()
        response.delete_cookie('ututi_session_lifetime')
        return None

    return User.get_byid(login)

def sign_in_user(user, long_session=False):
    set_geolocation(user)

    session['login'] = user.id
    session['cookie_secret'] = ''.join(Random().sample(string.ascii_lowercase, 20))
    expiration_time = 3600*24*30 if long_session else None
    response.set_cookie('ututi_session_lifetime', session['cookie_secret'], max_age = expiration_time)
    session.save()

def sign_out_user():
    if 'login' in session:
        del session['login']
    response.delete_cookie('ututi_session_lifetime')
    session.save()

def sign_in_admin_user(admin_user):
    session['admin_login'] = admin_user.email
    session.save()

def sign_out_admin_user():
    if 'admin_login' in session:
        del session['admin_login']
    session.save()

def is_root(user, context=None):
    return bool(session.get('admin_login', None))

def is_marketingist(user, context=None):
    if user is None:
        return False

    from ututi.model import meta, File, LocationTag, Group, GroupMember

    if isinstance(context, File):
        context = context.parent

    moderator_tags = meta.Session.query(LocationTag
            ).join(Group
            ).join(GroupMember
            ).filter(Group.moderators == True
            ).filter(GroupMember.user == user
            ).all()

    if moderator_tags: 
        return True

    return False

def is_moderator(user, context=None):
    if user is None:
        return False

    from ututi.model import meta, File, LocationTag, Group, GroupMember

    if isinstance(context, File):
        context = context.parent

    moderator_tags = meta.Session.query(LocationTag
            ).join(Group
            ).join(GroupMember
            ).filter(Group.moderators == True
            ).filter(GroupMember.user == user
            ).all()

    if isinstance(context, LocationTag):
        location = context
    else:
        location = getattr(context, 'location')

    for tag in moderator_tags:
        if location in tag.flatten:
            return True

    return False


def is_member(user, context=None):
    """The user is a member of the group."""
    from ututi.model import Group, File
    if isinstance(context, File) and isinstance(context.parent, Group):
        context = context.parent

    return context.is_member(user)


def is_admin(user, context=None):
    """The user is an administrator of the group."""
    from ututi.model import Group, File
    if isinstance(context, File) and isinstance(context.parent, Group):
        context = context.parent

    return context.is_admin(user)


def is_user(user, context=None):
    return user is not None

def is_teacher(user, context=None):
    return user is not None and user.is_teacher

def is_verified_teacher(user, context=None):
    return user is not None and user.is_teacher and user.teacher_verified

def is_group_teacher(user, context=None):
    return is_verified_teacher(user, context) and context.teacher == user

def is_owner(user, context=None):
    return context.created is user

def is_deleter(user, context=None):
    return context.deleted is user

def is_smallfile(user, context=None):
    from ututi.model import Subject, File

    if isinstance(context, File) and isinstance(context.parent, Subject):
        return context.size < int(config.get('small_file_size', 1024**3))
    return False


crowd_checkers = {
    "root": is_root,
    "marketingist": is_marketingist,
    "moderator": is_moderator,
    "admin": is_admin,
    "member": is_member,
    "owner": is_owner,
    "deleter": is_deleter,
    "user": is_user,
    "teacher": is_teacher,
    "verified_teacher": is_verified_teacher,
    "group_teacher": is_group_teacher,
    "smallfile": is_smallfile,
    }


def check_crowds(crowds, user=None, context=None):
    # TODO: log crowd checking to see if it is run that often
    if context is None:
        context = c.security_context
    if user is None:
        user = c.user
    for crowd in crowds:
        if crowd_checkers[crowd](user, context):
            return True
    if is_root(user, context):
        return True
    return False


class CrowdPredicate(object):

    def __init__(self, *crowds):
        self.crowds = crowds

    def check_authorization(self, environment):
        if not check_crowds(self.crowds):
            raise NotAuthorizedError()


def deny(reason, code=403):
    if code is not None:
        response.status_int = code

    # User is logged in, we don't want to tell him to log in again
    if c.user and response.status_int == 401:
        response.status_int = 403

    if response.status_int == 401:
        login_form_url =  c.login_form_url or url(controller='home',
                                                  action='login',
                                                  came_from=request.url)
        redirect(login_form_url)

    request.environ['ututi.access_denied_reason'] = reason
    abort(response.status_int, comment=reason)


class ActionProtector(BaseActionProtector):

    def default_denial_handler(self, reason):
        deny(reason, response.status_int)

    def __init__(self, *crowds, **kwargs):
        self.predicate = CrowdPredicate(*crowds)
        self.denial_handler = kwargs.get('denial_handler', self.default_denial_handler)


def bot_protect(method):
    """Decorator to protect actions from bots. Currently works for googlebot."""
    def _protected(self):
        ua  = request.headers.get('user-agent')
        bot = re.compile('googlebot', re.IGNORECASE)
        if ua is not None and bot.search(ua):
            abort(404)
        return method(self)
    return _protected
