import logging

from pylons.controllers.util import redirect, abort

from ututi.lib.base import BaseController
from ututi.model import ContentItem
from ututi.model.users import User

log = logging.getLogger(__name__)


class ContentController(BaseController):

    def get_content(self, id=None, next_action=None):
        try:
            id = int(id)
        except (ValueError, TypeError):
            abort(404)

        content_item = ContentItem.get(id)

        if content_item is None:
            abort(404)

        if next_action is None:
            redirect(content_item.url())
        else:
            redirect(content_item.url(action=next_action))

    def get_user(self, id=None):
        try:
            id = int(id)
        except (ValueError, TypeError):
            abort(404)

        user = User.get_byid(id)

        if user is None:
            abort(404)

        redirect(user.url())
