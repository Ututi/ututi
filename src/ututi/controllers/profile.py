import logging

from sqlalchemy.orm.exc import NoResultFound
from pylons.controllers.util import abort

from ututi.lib.image import serve_image
from ututi.lib.base import BaseController

from ututi.model import meta, User

log = logging.getLogger(__name__)


class ProfileController(BaseController):

    def logo(self, id):
        try:
            user = meta.Session.query(User).filter_by(id = id).one()
        except NoResultFound:
            abort(404)

        return serve_image(user.logo)
