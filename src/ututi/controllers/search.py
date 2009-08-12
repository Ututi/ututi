import logging

from pylons.decorators import validate
from pylons import request, c
from formencode import Schema, validators, Invalid, variabledecode
from webhelpers import paginate

from ututi.lib.base import BaseController, render
from ututi.lib.search import search_query

log = logging.getLogger(__name__)

class SearchSubmit(Schema):
    """Search form input validation."""
    allow_extra_fields = True
    pre_validators = [variabledecode.NestedVariables()]


class SearchController(BaseController):
    @validate(schema=SearchSubmit, form='test', post_only = False, on_get = True)
    def index(self):
        c.text = self.form_result.get('text', '')
        c.tags = self.form_result.get('tagsitem', None)
        if c.tags is None:
            c.tags = self.form_result.get('tags', '')
        else:
            c.tags = ', '.join(c.tags)

        c.obj_type = self.form_result.get('obj_type', '*')

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = self.form_result.get('tagsitem', c.tags.split(', '))
        if c.obj_type != '*' and c.obj_type in ('group', 'page', 'subject'):
            search_params['obj_type'] = c.obj_type
        if search_params != {}:
            c.results = paginate.Page(
                search_query(**search_params),
                page=int(request.params.get('page', 1)),
                items_per_page = 10,
                **search_params)

        return render('/search/index.mako')

    def test(self):
        return render('/search/index.mako')
