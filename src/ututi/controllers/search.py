import logging

from formencode import Schema, variabledecode
from webhelpers import paginate

from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons import request, tmpl_context as c, url
from pylons.templating import render_mako_def

from ututi.lib.base import BaseController, render
from ututi.lib.search import search_query, search_query_count

log = logging.getLogger(__name__)


class SearchSubmit(Schema):
    """Search form input validation."""

    allow_extra_fields = True
    pre_validators = [variabledecode.NestedVariables()]


class SearchBaseController(BaseController):
    """ A base controller for searching."""

    def _search(self):
        c.text = self.form_result.get('text', '')
        c.tags = self.form_result.get('tagsitem', None)
        if c.tags is None:
            c.tags = self.form_result.get('tags', '').split(', ')
        c.tags = ', '.join(filter(bool, c.tags))

        c.obj_type = self.form_result.get('obj_type', '*')

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        if c.obj_type != '*' and c.obj_type in ('group', 'page', 'subject'):
            search_params['obj_type'] = c.obj_type

        if search_params != {}:
            query = search_query(**search_params)
            c.results = paginate.Page(
                query,
                page=int(request.params.get('page', 1)),
                items_per_page = 30,
                item_count = search_query_count(query),
                **search_params)
            c.searched = True

class SearchController(SearchBaseController):

    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def index(self):
        if c.user is not None and self.form_result == {}:
            redirect_to(url(controller='profile', action='browse'))

        self._search()
        return render('/search/index.mako')

    @validate(schema=SearchSubmit, post_only = False, on_get = True)
    def search_js(self):
        self._search()
        return render_mako_def('/search/index.mako','search_results', results=c.results, controller='search', action='index')

