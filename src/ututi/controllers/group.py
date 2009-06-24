import logging

from ututi.lib.base import BaseController, render
from pylons import c
from pylons.i18n import _
from ututi.model import meta, Group
from routes import url_for
from pylons.controllers.util import abort
from sqlalchemy.orm.exc import NoResultFound

log = logging.getLogger(__name__)

class GroupController(BaseController):
    """Controller for group actions."""
    def __before__(self):
        c.breadcrumbs = [
            {'title' : _('Groups'),
             'link' : url_for(controller = 'group', action = 'index')}
            ]

    def index(self):
        c.groups = meta.Session.query(Group).all()
        return render('groups.mako')

    def group_home(self, id):
        try:
            c.group = meta.Session.query(Group).filter_by(id = id).one()
            c.breadcrumbs = [
                {'title' : c.group.title,
                 'link' : url_for(controller = 'group', action = 'group_home', id = c.group.id)}
                ]

            return render('group_home.mako')
        except NoResultFound:
            abort(404)
