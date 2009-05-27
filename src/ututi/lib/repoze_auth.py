from ututi.model import User


class UserModelPlugin(object):

    def authenticate(self, environ, identity):
        try:
            username = identity['login']
            password = identity['password']
        except KeyError:
            return None

        success = User.authenticate(username, password)

        return success

    def add_metadata(self, environ, identity):
        username = identity.get('repoze.who.userid')
        user = User.get(username)

        if user is not None:
            identity['user'] = user
