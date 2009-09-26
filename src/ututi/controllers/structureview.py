import logging

from pylons.controllers.util import abort
from pylons import c, url
from pylons.decorators import validate

from ututi.lib.base import render
from ututi.model import LocationTag

from ututi.controllers.search import SearchSubmit, SearchBaseController

log = logging.getLogger(__name__)

def location_action(method):
    def _location_action(self, path):
        location = LocationTag.get(path)

        if location is None:
            abort(404)

        c.security_context = location
        c.object_location = None
        c.location = location
        return method(self, location)
    return _location_action


class StructureviewController(SearchBaseController):

    @location_action
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def index(self, location):
        c.breadcrumbs = []
        for tag in location.hierarchy(True):
            bc = {'link': tag.url(),
                  'title': tag.title_short}
            if tag.logo is not None:
                bc['logo'] = url(controller='structure', action='logo', width=30, height=30, id=tag.id)
            c.breadcrumbs.append(bc)

        self.form_result['tagsitem'] = location.hierarchy()
        self._search()

        if location.parent is None:
            return render('location/university.mako')
        else:
            return render('location/department.mako')

