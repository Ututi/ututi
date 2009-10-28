from pylons import response, url, request, session, c
from pylons.controllers.util import abort
from pylons.controllers.util import redirect_to

from repoze.what.predicates import NotAuthorizedError
from repoze.what.plugins.pylonshq.protectors import ActionProtector as BaseActionProtector

def current_user():
    from ututi.model import User
    login = session.get('login', '')
    password = session.get('password', '')
    return User.get(login)


def is_root(user, context=None):
    return user is not None and user.id == 1


def is_moderator(user, context=None):
    if user is None:
        return False

    from ututi.model import File
    if isinstance(context, File):
        context = context.parent

    moderator_tags = [group.location for group in user.groups
                      if group.moderators]
    from ututi.model import LocationTag

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


def is_owner(user, context=None):
    return context.created is user


crowd_checkers = {
    "root": is_root,
    "moderator": is_moderator,
    "admin": is_admin,
    "member": is_member,
    "owner": is_owner,
    "user": is_user,
    }


def check_crowds(crowds, user=None, context=None):
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


def deny(reason, code=None):
    if code is not None:
        response.status_int = code

    if response.status_int == 401:
        login_form_url =  c.login_form_url or url(controller='home',
                                                  action='index',
                                                  came_from=request.url)
        redirect_to(login_form_url)

    abort(response.status_int, comment=reason)


class ActionProtector(BaseActionProtector):

    def default_denial_handler(self, reason):
        deny(reason)

    def __init__(self, *crowds, **kwargs):
        self.predicate = CrowdPredicate(*crowds)
        self.denial_handler = kwargs.get('denial_handler', self.default_denial_handler)
