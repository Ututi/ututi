import logging

from datetime import datetime, date
from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, htmlfill
#from pylons import tmpl_context as c, request, url
#from routes.util import url_for



from pylons.controllers.util import redirect
from pylons.i18n import _

from ututi.controllers.group import FileUploadTypeValidator
from ututi.model import Book, meta
import ututi.lib.helpers as h
from ututi.lib.forms import validate
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render, render_lang, u_cache
from pylons import request, tmpl_context as c, url, config, session

#class BookForm(Schema):
#    """A schema for validating new books forms."""
#
#    allow_extra_fields = True
#
#    pre_validators = [NestedVariables()]
#
#    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
#                    LocationTagsValidator(not_empty=True))
#
#    title = validators.UnicodeString(not_empty=True, strip=True)
#    lecturer = validators.UnicodeString(strip=True)
#    chained_validators = [
#        TagsValidator()
#        ]
#
#
#class NewBookForm(BookForm):
#    pass
#

class CoverUpload(Schema):
    """A schema for validating books uploads."""
    cover = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))

class BooksController(BaseController):

    def index(self):
        c.books = meta.Session.query(Book).all()
        return render('books/index.mako')

    @validate(CoverUpload)
    @ActionProtector("user")
    def create(self):
        title = request.POST['title']
        price = request.POST['price']
        owner_id = c.user.id
        book = Book(owner_id, title, price)
        book.author = request.POST['author']
        book.publisher = request.POST['publisher']
        book.description = request.POST['description']
        pages_number = request.POST['pages_number']
        if pages_number is None:
            pages_number = 01
            book.pages_number = pages_number
        if request.POST['year'] is not None:
            book.year = datetime.strptime(request.POST['year'], "%Y").date()
        if request.POST['cover'] is not None:
            book.cover = request.POST['cover'].file.read()
        book.location = request.POST['location']
        meta.Session.add(book)
        meta.Session.commit()
        h.flash(_('Book was added succesfully'))
        redirect(url(controller='books', action='index'))

    @ActionProtector("user")
    def add(self):
        return render('books/add.mako')

    def show(self):
        return render('books/show.mako')

    @ActionProtector("user")
    def update(self):
        redirect(url(controller='books', action='show'))
