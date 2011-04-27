import logging

from formencode import Schema, variabledecode
from webhelpers import paginate

from pylons.controllers.util import redirect
from pylons import request, tmpl_context as c, url
from pylons.controllers.util import abort
from pylons.templating import render_mako_def

from ututi.controllers.home import UniversityListMixin
from ututi.lib.base import BaseController, render
from ututi.lib.search import search_query, search_query_count, tag_search
from ututi.lib.validators import validate

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
        if c.obj_type != '*':
            search_params['obj_type'] = c.obj_type

        try:
            page_no = int(request.params.get('page', 1))
        except ValueError:
            abort(404)
        c.page = page_no

        if search_params != {}:
            query = search_query(**search_params)
            c.results = paginate.Page(
                query,
                page=c.page,
                items_per_page = 30,
                item_count = search_query_count(query),
                **search_params)
            c.searched = True

    def _search_locations(self, text):
        c.tag_search = tag_search(text)

class SearchController(SearchBaseController, UniversityListMixin):

    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def index(self):
        if c.user is not None and self.form_result == {}:
            redirect(url(controller='profile', action='browse'))

        self._search()
        self._search_locations(c.text)
        return render('/search/index.mako')

    def browse(self):
        self._get_unis()
        c.teaser = False

        c.obj_type = '*'
        if request.params.has_key('js'):
            return render_mako_def('/anonymous_index/lt.mako', 'universities', unis=c.unis, ajax_url=url(controller='search', action='browse'))

        return render('/search/browse.mako')

    @validate(schema=SearchSubmit, post_only=False, on_get=True)
    def search_js(self):
        self._search()
        self._search_locations(c.text)
        return render_mako_def('/search/index.mako', 'search_results', results=c.results, controller='search', action='search_js')

