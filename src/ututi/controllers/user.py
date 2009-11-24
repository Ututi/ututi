import logging

from pkg_resources import resource_stream

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import desc
from pylons.controllers.util import abort
from pylons import c
from routes import url_for
from routes.util import redirect_to

from ututi.controllers.home import sign_in_user
from ututi.lib.security import ActionProtector
from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render

from ututi.model import meta, User, ContentItem
from ututi.model.events import Event

log = logging.getLogger(__name__)


def profile_action(method):
    def _profile_action(self, id):
        try:
            id = int(id)
        except ValueError:
            abort(404)

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
        c.events = meta.Session.query(Event)\
            .join(Event.context)\
            .filter(Event.author_id == user.id)\
            .filter(ContentItem.content_type == 'subject')\
            .order_by(desc(Event.created))\
            .limit(20).all()

        if user is c.user:
            redirect_to(controller='profile', action='index')
        return render('user/index.mako')

    @profile_action
    @ActionProtector("root")
    def login_as(self, user):
            sign_in_user(user.emails[0].email)
            redirect_to(controller='profile', action='home')

    def logo(self, id, width=None, height=None):
        try:
            user = meta.Session.query(User).filter_by(id=id).one()
            if user.logo is not None:
                return serve_image(user.logo, width, height)
            else:
                stream = resource_stream("ututi", "public/images/details/icon_user.png").read()
                return serve_image(stream, width, height)

        except NoResultFound:
            abort(404)
