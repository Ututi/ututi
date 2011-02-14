import logging

from formencode import Schema, validators, htmlfill

from lxml.html.diff import htmldiff

from pylons import tmpl_context as c, request, url
from pylons.controllers.util import abort, redirect

from ututi.controllers.group import group_action, group_menu_items

from ututi.model import Group, Page, PageVersion
from ututi.model import meta
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.lib.helpers import html_cleanup, literal, check_crowds
from ututi.lib.validators import validate
from pylons.i18n import _

log = logging.getLogger(__name__)

def set_login_url(method):
    def _set_login_url(self, id):
        c.login_form_url = url(controller='home',
                               action='join',
                               came_from=url.current())
        return method(self, id)
    return _set_login_url


class PageForm(Schema):
    """A schema for validating pages."""

    allow_extra_fields = True
    page_title = validators.UnicodeString(strip=True, not_empty=True)
    page_content = validators.UnicodeString(strip=True, not_empty=True)


def page_action(method):
    def _page_action(self, id, page_id):
        try:
            page_id = int(page_id)
        except ValueError:
            abort(404)

        group = Group.get(id)
        if group is None:
            abort(404)
        page = Page.get(page_id)
        if page is None:
            abort(404)

        location = group.location
        if location is None:
            abort(404)

        c.page = page
        c.group = group
        c.object_location = group.location
        c.security_context = group
        c.group_menu_items = group_menu_items()
        return method(self, group, page)
    return _page_action


class GrouppageController(BaseController):
    """Controller for creating, editing and viewing group pages."""

    @page_action
    @ActionProtector("member", "admin")
    def index(self, group, page):
        c.breadcrumbs = [{'link': group.url(),
                          'title': group.title},
                         {'link': page.url('grouppage'),
                          'title': page.title}]

        if page not in group.pages:
            abort(404)
        if page.isDeleted() and not check_crowds(['moderator']):
            abort(404)

        return render('page/view.mako')

    @page_action
    @ActionProtector("member", "admin")
    def history(self, group, page):
        c.breadcrumbs = [{'link': group.url(),
                          'title': group.title},
                         {'link': page.url('grouppage'),
                          'title': page.title}]
        if page not in group.pages:
            abort(404)
        return render('page/history.mako')

    @page_action
    @ActionProtector("member", "admin")
    def show_version(self, group, page):
        c.breadcrumbs = [{'link': group.url(),
                          'title': group.title},
                         {'link': page.url('grouppage'),
                          'title': page.title}]
        if page not in group.pages:
            abort(404)
        version_id = int(request.GET['version_id'])
        c.version = PageVersion.get(version_id)
        return render('page/version.mako')

    @page_action
    @ActionProtector("member", "admin")
    def diff_with_previous(self, group, page):
        c.breadcrumbs = [{'link': group.url(),
                          'title': group.title},
                         {'link': page.url('grouppage'),
                          'title': page.title}]
        if page not in group.pages:
            abort(404)
        version_id = int(request.GET['version_id'])
        c.version = PageVersion.get(version_id)
        idx = page.versions.index(c.version)
        c.prev_version = page.versions[idx+1]
        c.diff = literal(htmldiff(html_cleanup(c.prev_version.content),
                                  html_cleanup(c.version.content)))
        return render('page/diff_with_previous.mako')

    @page_action
    @ActionProtector("member", "admin")
    def restore(self, group, page):
        version_id = int(request.GET['version_id'])
        version = PageVersion.get(version_id)
        page.save(version.title, version.content)
        meta.Session.commit()
        redirect(page.url())

    @page_action
    @ActionProtector("member", "admin")
    def delete(self, group, page):
        page.deleted = c.user
        meta.Session.commit()
        redirect(page.url())

    @page_action
    @ActionProtector("member", "admin")
    def undelete(self, group, page):
        page.deleted_by = None
        meta.Session.commit()
        redirect(page.url())

    @group_action
    @ActionProtector("member", "admin")
    def add(self, group):
        c.breadcrumbs = [{'link': c.group.url(),
                          'title': c.group.title},
                         {'link': group.url(controller='grouppage', action='add'),
                          'title': _('New page')}]

        return render('page/add.mako')

    @group_action
    @set_login_url
    @validate(schema=PageForm, form='add')
    @ActionProtector("member", "admin")
    def create(self, group):
        if not hasattr(self, 'form_result'):
            redirect(url.current(action='add'))

        location = group.location
        page = Page(self.form_result['page_title'],
                    self.form_result['page_content'])
        group.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        redirect(url.current(action='index', page_id=page.id))

    def _edit_form(self):
        return render('page/edit.mako')

    @page_action
    @validate(schema=PageForm, form='edit')
    @ActionProtector("user")
    def edit(self, group, page):
        c.group = group
        c.breadcrumbs = [{'link': group.url(),
                          'title': group.title},
                         {'link': page.url('grouppage'),
                          'title': page.title}]

        defaults = {
            'page_title': page.title,
            'page_content': page.content
            }

        return htmlfill.render(self._edit_form(), defaults=defaults)

    @page_action
    @validate(schema=PageForm, form='_edit_form')
    @ActionProtector("user")
    def update(self, group, page):
        page.save(self.form_result['page_title'],
                  self.form_result['page_content'])
        meta.Session.commit()
        redirect(url.current(action='index'))
