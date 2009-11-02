from datetime import date

from pylons import c, url
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
from pylons.decorators import validate

from formencode import Schema, validators, htmlfill
from sqlalchemy.orm.exc import NoResultFound

from ututi.lib.security import ActionProtector
from ututi.model import meta, BlogEntry
from ututi.lib.base import BaseController, render
from ututi.lib import helpers as h


class SnippetForm(Schema):
    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True, max=50)
    url = validators.URL()
    date = validators.UnicodeString(not_empty=True, max=11)
    content = validators.UnicodeString(not_empty=True)


class SnippetUpdateForm(SnippetForm):
    id = validators.Int()

class BlogController(BaseController):
    """Controller for managing blog entry snippets."""

    def __before__(self):
        c.blog_entries = meta.Session.query(BlogEntry).order_by(BlogEntry.created.desc()).limit(10).all()

    @ActionProtector("root")
    def index(self):
        c.items = meta.Session.query(BlogEntry).order_by(BlogEntry.created.desc()).all()
        return render('blogentries/index.mako')

    def _snippet_form(self):
        return render('blogentries/add.mako')

    def _snippet_edit_form(self):
        return render('blogentries/edit.mako')

    @ActionProtector("root")
    @validate(schema=SnippetForm, form='_snippet_form')
    def create(self):
        if hasattr(self, 'form_result'):
            blog = BlogEntry()
            blog.title = self.form_result.get('title')
            blog.url = self.form_result.get('url')
            blog.date = self.form_result.get('date')
            blog.content = self.form_result.get('content')
            meta.Session.add(blog)
            meta.Session.commit()
            h.flash(_('Blog snippet created.'))
            redirect_to(url(controller='blog', action='index'))

    @ActionProtector("root")
    def add(self):
        defaults = {'date': date.today()}
        return htmlfill.render(self._snippet_form(), defaults=defaults)

    @ActionProtector("root")
    def edit(self, id):
        try:
            snippet = meta.Session.query(BlogEntry).filter(BlogEntry.id == id).one()
            defaults = {
                'id' : snippet.id,
                'title': snippet.title,
                'date': snippet.created,
                'url': snippet.url,
                'content': snippet.content}
            return htmlfill.render(self._snippet_edit_form(), defaults=defaults)
        except NoResultFound:
            abort(404)

    @ActionProtector("root")
    @validate(schema=SnippetUpdateForm, form='_snippet_edit_form')
    def update(self):
        try:
            id = self.form_result.get('id', None)
            snippet = meta.Session.query(BlogEntry).filter(BlogEntry.id == id).one()

            if self.form_result.has_key('delete'):
                meta.Session.delete(snippet)
                h.flash(_('Blog snippet deleted.'))
            else:
                snippet.title = self.form_result.get('title', snippet.title)
                snippet.created = self.form_result.get('date', snippet.created)
                snippet.url = self.form_result.get('url', snippet.url)
                snippet.content = self.form_result.get('content', snippet.content)
                h.flash(_('Blog snippet updated.'))

            meta.Session.commit()
            redirect_to(url(controller='blog', action='index'))
        except NoResultFound:
            abort(404)
