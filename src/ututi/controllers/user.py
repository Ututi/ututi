import logging

from sqlalchemy.orm.exc import NoResultFound
from pylons.controllers.util import abort
from pylons import c
from pylons.i18n import _
from routes import url_for

from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render

from ututi.model import meta, User

log = logging.getLogger(__name__)


def profile_action(method):
    def _profile_action(self, id):
        user = User.get_byid(id)
        if user is None:
            abort(404)
        return method(self, user)
    return _profile_action


class UserController(BaseController):

    @profile_action
    def index(self, user):
        c.user_info = user
        c.breadcrumbs = [
            {'title': user.fullname,
             'link': url_for(controller='user', action='index', id=user.id)}
            ]

        return render('user/index.mako')

    def logo(self, id, width=None, height=None):
        try:
            user = meta.Session.query(User).filter_by(id=id).one()
        except NoResultFound:
            abort(404)

        return serve_image(user.logo, width, height)
