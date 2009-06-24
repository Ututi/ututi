import logging

from ututi.lib.base import BaseController, render
from formencode import Schema, validators, Invalid
from pylons import c, request
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _
from ututi.model import meta, Group
from routes import url_for
from sqlalchemy.orm.exc import NoResultFound
from datetime import date
import re

log = logging.getLogger(__name__)

class GroupIdValidator(validators.FancyValidator):
    """A validator that makes sure the group id is unique."""
    messages = {
        'duplicate' : _(u"Such id already exists, choose a different one."),
        'badId' : _(u"Id cannot be used as an email address.")
        }

    def _to_python(self, value, state):
        return value.strip()

    def validate_python(self, value, state):
        if value != 0:
            try:
                meta.Session.query(Group).filter_by(id = value).one()
                raise Invalid(self.message('duplicate', state), value, state)
            except NoResultFound:
                pass

            usernameRE = re.compile(r"^[^ \t\n\r@<>()]+$", re.I)
            if not usernameRE.search(value):
                raise Invalid(self.message('badId', state), value, state)

class NewGroupForm(Schema):
    """A schema for validating new group forms."""
    allow_extra_fields = True

    id = GroupIdValidator()

    title = validators.String(not_empty = True)


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

    def add(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group_add.mako')

    @validate(schema=NewGroupForm, form='add')
    def new_group(self):
        fields = ('id', 'title', 'description', 'year')
        values = {}
        for field in fields:
             values[field] = request.POST.get(field, None)

        group = Group(id = values['id'],
                      title = values['title'],
                      description = values['description'],
                      year = date(int(values['year']), 1, 1))
        meta.Session.add(group)
        meta.Session.commit()

        redirect_to(controller='group', action='index')
