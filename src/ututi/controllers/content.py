import logging

from pylons.controllers.util import redirect

from ututi.lib.base import BaseController
from ututi.model import ContentItem
from ututi.model.users import User

log = logging.getLogger(__name__)


class ContentController(BaseController):

    def get_content(self, id, next_action=None):
        content_item = ContentItem.get(id)
        if next_action is None:
            redirect(content_item.url())
        else:
            redirect(content_item.url(action=next_action))

    def get_user(self, id):
        user = User.get_by_id(id)
        redirect(user.url())
