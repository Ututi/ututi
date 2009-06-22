import logging

from ututi.lib.base import BaseController, render
from pylons import c
from ututi.model import meta, Group

log = logging.getLogger(__name__)

class GroupController(BaseController):
    """Controller for group actions."""
    def index(self):
        c.groups = meta.Session.query(Group).all()
        return render('groups.mako')
