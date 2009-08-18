from pylons import c
from repoze.what.predicates import NotAuthorizedError
from repoze.what.plugins.pylonshq.protectors import ActionProtector as BaseActionProtector


def is_root(user, context=None):
    return user is not None and user.id == 1


def is_moderator(user, context=None):
    return False


def is_member(user, context=None):
    return context.is_member(user)


def is_admin(user, context=None):
    return context.is_admin(user)


def is_user(user, context=None):
    return user is not None


def is_owner(user, context=None):
    return context.created_by is user


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
    if is_root(user, context):
        return True
    for crowd in crowds:
        if crowd_checkers[crowd](user, context):
            return True
    return False


class CrowdPredicate(object):

    def __init__(self, *crowds):
        self.crowds = crowds

    def check_authorization(self, environment):
        if not check_crowds(self.crowds):
            raise NotAuthorizedError()


class ActionProtector(BaseActionProtector):

    def __init__(self, *crowds, **kwargs):
        self.predicate = CrowdPredicate(*crowds)
        self.denial_handler = kwargs.get('denial_handler', self.default_denial_handler)
