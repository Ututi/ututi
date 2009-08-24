import logging

from routes.util import url_for
from formencode import Schema, validators

from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort

from ututi.model import Subject
from ututi.model import LocationTag
from ututi.model import meta, Page
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render

from pylons.i18n import _

log = logging.getLogger(__name__)


class PageForm(Schema):
    """A schema for validating pages."""

    allow_extra_fields = True
    page_title = validators.UnicodeString(strip=True, not_empty=True)
    page_content = validators.UnicodeString(strip=True, not_empty=True)


def page_action(method):
    def _page_action(self, id, tags, page_id):
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
        c.object_location = subject.location
        return method(self, subject, page)
    return _page_action


class SubjectpageController(BaseController):
    """Controller for creating, editing and viewing subject pages."""

    @page_action
    def index(self, subject, page):
        if page not in subject.pages:
            abort(404)
        return render('page/view.mako')

    def add(self):
        return render('page/add.mako')

    @validate(schema=PageForm, form='add')
    @ActionProtector("user")
    def create(self, id, tags):
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)
        page = Page(self.form_result['page_title'],
                    self.form_result['page_content'])
        subject.pages.append(page)
        meta.Session.add(page)
        meta.Session.commit()
        redirect_to(url_for(action='index', page_id=page.id))

    @page_action
    @validate(schema=PageForm, form='edit')
    @ActionProtector("user")
    def edit(self, subject, page):
        return render('page/edit.mako')

    @page_action
    @validate(schema=PageForm, form='edit')
    @ActionProtector("user")
    def update(self, subject, page):
        page.add_version(self.form_result['page_title'],
                         self.form_result['page_content'])
        meta.Session.commit()
        redirect_to(url_for(action='index'))
