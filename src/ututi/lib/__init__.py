from pylons import request

def current_user():
    identity = request.environ.get('repoze.who.identity')
    if identity is not None:
        user = identity.get('user')
        return user
    else:
        return None

