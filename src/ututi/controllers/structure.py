import logging

from formencode import Schema, validators, Invalid, All

from pylons import request, response, c
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib import current_user, email_confirmation_request

from ututi.model import meta, LocationTag

log = logging.getLogger(__name__)

class StructureIdValidator(validators.FancyValidator):
    messages = {
        'not_exist' : _(u"The element does not exist.")
        }

    def _to_python(self, value, state):
        return int(value.strip())

    def validate_python(self, value, state):
        if value != 0:
            try:
                meta.Session.query(LocationTag).filter_by(id = value).one()
            except:
                raise Invalid(self.message('not_exist', state), value, state)


class NewStructureForm(Schema):
    allow_extra_fields = False

    title = validators.String(not_empty = True)
    title_short = validators.String(not_empty = True, max = 50)

    description = validators.String()
    parent = StructureIdValidator()

class StructureController(BaseController):
    def index(self):
        c.structure = meta.Session.query(LocationTag).filter_by(parent = None).all()
        return render('structure.mako')

    @validate(schema=NewStructureForm, form='index')
    def create_structure(self):
        fields = ('title', 'title_short', 'description', 'parent')
        values = {}
        for field in fields:
            values[field] = request.POST.get(field, None)

        structure = LocationTag(title = values['title'],
                                title_short = values['title_short'],
                                description = values['description'])
        meta.Session.add(structure)
        if int(values['parent']) != 0:
            parent = meta.Session.query(LocationTag).filter_by(id=values['parent']).one()
            parent.children.append(structure)
        meta.Session.commit()
        redirect_to(controller='structure', action='index')

