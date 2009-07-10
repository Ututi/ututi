import logging

from ututi.lib.base import BaseController, render
from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
from ututi.model import meta, Page, PageVersion
from routes import url_for
from sqlalchemy.orm.exc import NoResultFound
from formencode import Schema, validators, Invalid, All

log = logging.getLogger(__name__)

class PageForm(Schema):
    """A schema for validating pages."""
    allow_extra_fields = True
    page_content = validators.String()


def page_action(method):
    def _page_action(self, id):
        page = Page.get(id)
        if page is None:
            abort(404)
        return method(self, page)
    return _page_action


class PageController(BaseController):
    """A base controller for creating, editing and viewing pages.
    Meant to be extended by cotnrollers serving pages for groups or subjects."""

    _add_template = 'page/add.mako'
    _edit_template = 'page/edit.mako'
    _view_template = 'page/view.mako'
    _redirect_after_create = {'controller': 'page', 'action': 'view'}
    _redirect_after_update = {'controller': 'page', 'action': 'view'}

    def _on_create(self, page):
        """A method meant to be overridden by inheriting classes,
        provides a way to add additional processing after the page has been created."""
        self._redirect_after_create['id'] = page.id

    def _on_view(self, page):
        """A method meant to be overridden by inheriting classes.
        It is called before displaying the page."""
        pass

    def _on_edit(self, page):
        """A method called before displaying the page edit form."""
        pass

    def _on_update(self, page):
        pass

    def add(self):
        return render(self._add_template)

    @validate(schema=PageForm, form='add')
    def create_page(self):
        page = Page(request.POST.get('page_content', ''), c.user)
        meta.Session.add(page)
        meta.Session.flush()
        self._on_create(page)
        meta.Session.commit()
        redirect_to(**self._redirect_after_create)

    @page_action
    def view(self, page):
        c.page = page
        self._on_view(page)
        return render(self._view_template)

    @page_action
    def edit(self, page):
        c.page = page
        self._on_edit(page)
        return render(self._edit_template)

    @page_action
    @validate(schema=PageForm, form='edit')
    def update_page(self, page):
        page.add_version(request.POST.get('page_content', ''), c.user)
        meta.Session.flush()
        self._on_update(page)
        meta.Session.commit()
        redirect_to(**self._redirect_after_update)
