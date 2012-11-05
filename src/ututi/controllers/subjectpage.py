import logging

from formencode import Schema, validators, htmlfill

from lxml.html.diff import htmldiff

from pylons import tmpl_context as c, request, url
from pylons.controllers.util import abort, redirect

from ututi.controllers.subject import subject_action, find_similar_subjects, subject_menu_items, subject_privacy
from ututi.model import Subject, LocationTag, Page, PageVersion
from ututi.model import meta
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.lib.helpers import html_cleanup, literal, check_crowds
from ututi.lib.validators import validate

from pylons.i18n import _

log = logging.getLogger(__name__)

def set_login_url(method):
    def _set_login_url(self, id, tags):
        c.login_form_url = url('login', came_from=url.current())
        return method(self, id, tags)
    return _set_login_url


class PageForm(Schema):
    """A schema for validating pages."""

    allow_extra_fields = True
    page_title = validators.UnicodeString(strip=True, not_empty=True)
    page_content = validators.UnicodeString(strip=True, not_empty=True)


def page_action(method):
    def _page_action(self, id, tags, page_id):
        try:
            page_id = int(page_id)
        except ValueError:
            abort(404)

        location = LocationTag.get(tags)
        if location is None:
            abort(404)

        subject = Subject.get(location, id)
        if subject is None:
            abort(404)
        page = Page.get(page_id)
        if page is None:
            abort(404)

        c.page = page
        c.subject = subject

        c.similar_subjects = find_similar_subjects(location.id, id)
        c.object_location = subject.location
        c.security_context = subject
        c.tabs = subject_menu_items()
        c.theme = location.get_theme()

        return method(self, subject, page)
    return _page_action


class SubjectpageController(BaseController):
    """Controller for creating, editing and viewing subject pages."""

    @page_action
    @subject_privacy
    def index(self, subject, page):
        if page not in subject.pages:
            abort(404)
        if page.isDeleted() and not check_crowds(['moderator']):
            abort(404)
        c.current_tab = 'pages'
        return render('page/view.mako')

    @page_action
    @subject_privacy
    @ActionProtector("user")
    def history(self, subject, page):
        c.breadcrumbs = [{'link': subject.url(),
                          'title': subject.title},
                         {'link': page.url(),
                          'title': page.title}]
        if page not in subject.pages:
            abort(404)
        return render('page/history.mako')

    @page_action
    @subject_privacy
    @ActionProtector("user")
    def show_version(self, subject, page):
        c.breadcrumbs = [{'link': subject.url(),
                          'title': subject.title},
                         {'link': page.url(),
                          'title': page.title}]
        if page not in subject.pages:
            abort(404)
        version_id = int(request.GET['version_id'])
        c.version = PageVersion.get(version_id)
        return render('page/version.mako')

    @page_action
    @subject_privacy
    @ActionProtector("user")
    def diff_with_previous(self, subject, page):
        c.breadcrumbs = [{'link': subject.url(),
                          'title': subject.title},
                         {'link': page.url(),
                          'title': page.title}]
        if page not in subject.pages:
            abort(404)
        version_id = int(request.GET['version_id'])
        c.version = PageVersion.get(version_id)
        idx = page.versions.index(c.version)
        c.prev_version = page.versions[idx+1]
        c.diff = literal(htmldiff(html_cleanup(c.prev_version.content),
                                  html_cleanup(c.version.content)))
        return render('page/diff_with_previous.mako')

    @page_action
    @subject_privacy
    @ActionProtector("user")
    def restore(self, subject, page):
        version_id = int(request.GET['version_id'])
        version = PageVersion.get(version_id)
        page.save(version.title, version.content)
        meta.Session.commit()
        redirect(page.url())

    @page_action
    @subject_privacy
    @ActionProtector("moderator")
    def delete(self, subject, page):
        page.deleted = c.user
        meta.Session.commit()
        redirect(page.url())

    @page_action
    @subject_privacy
    @ActionProtector("moderator")
    def undelete(self, subject, page):
        page.deleted_by = None
        meta.Session.commit()
        redirect(page.url())

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def add(self, subject):
        c.breadcrumbs = [{'link': c.subject.url(),
                          'title': c.subject.title},
                         {'link': subject.url(controller='subjectpage', action='add'),
                          'title': _('New page')}]

        return render('page/add.mako')

    @set_login_url
    @validate(schema=PageForm, form='add')
    @ActionProtector("user")
    def create(self, id, tags):
        if not hasattr(self, 'form_result'):
            redirect(url.current(action='add'))
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)
        page = Page(self.form_result['page_title'],
                    self.form_result['page_content'])
        subject.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        redirect(url.current(action='index', page_id=page.id))

    def _edit_form(self):
        return render('page/edit.mako')

    @page_action
    @subject_privacy
    @validate(schema=PageForm, form='edit')
    @ActionProtector("user")
    def edit(self, subject, page):
        c.subject = subject
        c.breadcrumbs = [{'link': subject.url(),
                          'title': subject.title},
                         {'link': page.url(),
                          'title': page.title}]

        defaults = {
            'page_title': page.title,
            'page_content': page.content
            }

        return htmlfill.render(self._edit_form(), defaults=defaults)

    @page_action
    @subject_privacy
    @validate(schema=PageForm, form='_edit_form')
    @ActionProtector("user")
    def update(self, subject, page):
        page.save(self.form_result['page_title'],
                  self.form_result['page_content'])
        meta.Session.commit()
        redirect(url.current(action='index'))
