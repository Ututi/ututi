import logging

import string
from datetime import datetime, date
from formencode.validators import Number
from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, htmlfill
#from pylons import tmpl_context as c, request, url
#from routes.util import url_for



from pylons.controllers.util import redirect
from pylons.i18n import _

from ututi.controllers.group import FileUploadTypeValidator
from ututi.model import Book, meta, City, BookType, SchoolGrade, ScienceType
import ututi.lib.helpers as h
from ututi.lib.validators import LocationTagsValidator
from ututi.lib.image import serve_logo
from ututi.lib.forms import validate
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render, render_lang, u_cache
from pylons import request, tmpl_context as c, url, config, session
from webhelpers import paginate


class PriceValidator(Number):
    """Number validator that accepts numbers with dot and with comma (i.e. 3.14 and 3,14)"""

    messages = {
        'number': _("Please enter a number")
    }

    def _to_python(self, value, state):
        value = string.replace(value, ',', '.')
        return super(PriceValidator, self)._to_python(value, state)

class BookForm(Schema):
    pre_validators = [NestedVariables()]
    allow_extra_fields = True

    logo = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    title = validators.UnicodeString(not_empty=True)
    author = validators.UnicodeString(not_empty=True)
    price = PriceValidator(not_empty=True)
    description = validators.UnicodeString()
    location = Pipe(ForEach(validators.UnicodeString(strip=True)),
                    LocationTagsValidator())


class BooksController(BaseController):
    def _make_pages(self, items):
        return paginate.Page(items,
                             page=int(request.params.get('page', 1)),
                             item_count=items.count() or 0,
                             items_per_page=100)



    def index(self):
        books = meta.Session.query(Book)
        c.books = self._make_pages(books)
        return render('books/index.mako')

    def _load_defaults(self):
        c.book_departments = Book.departments
        c.book_types = meta.Session.query(BookType).all()
        c.school_grades = meta.Session.query(SchoolGrade).all()
        c.cities = meta.Session.query(City).all()
        c.science_types = meta.Session.query(ScienceType).all()

    @validate(schema=BookForm, form='_add')
    @ActionProtector("user")
    def create(self):
        if hasattr(self, 'form_result'):
            title = self.form_result['title']
            price = self.form_result['price']
            book = Book(c.user.id, title, price)
            book.author = self.form_result['author']
            book.description = self.form_result['description']
            if self.form_result['logo'] is not None and self.form_result['logo'] != '':
                book.logo = self.form_result['logo'].file.read()
            book.location = self.form_result['location']
            meta.Session.add(book)
            meta.Session.commit()
            h.flash(_('Book was added succesfully'))
            redirect(url(controller='books', action='show', id=book.id))
        else:
            return self._add()

    @ActionProtector("user")
    def _add(self):
        self._load_defaults
        return render('books/add.mako')

    def add(self):
        return self._add()

    def show(self, id):
        c.book = meta.Session.query(Book).filter(Book.id == id).one()
        return render('books/show.mako')

    def _edit(self):
        return render('books/edit.mako')

    @ActionProtector("user")
    def edit(self, id):
        book = meta.Session.query(Book).filter(Book.id == id).one()
        if book.owner != c.user:
            h.flash(_('Only owner of this book can do this action'))
            redirect(url(controller="books", action="index"))

        defaults = {
            'title': book.title,
            'author': book.author,
            'description': book.description,
            'price': book.price,
            'department': book.department,
            'city': book.city
        }
        if book.location is not None:
            location = dict([('location-%d' % n, tag)
                             for n, tag in enumerate(book.location.hierarchy())])
        else:
            location = []

        defaults.update(location)

        return htmlfill.render(self._edit(), defaults=defaults)

    @validate(BookForm, form='_edit')
    @ActionProtector("user")
    def update(self):
        if hasattr(self, 'form_result'):
            book = meta.Session.query(Book).filter(Book.id == self.form_result['id']).one()
            book.title = self.form_result['title']
            book.price = self.form_result['price']
            book.owner_id = c.user.id
            book.author = self.form_result['author']
            book.publisher = self.form_result['publisher']
            book.description = self.form_result['description']
            pages_number = self.form_result['pages_number']
            if pages_number is None:
                pages_number = 0
                book.pages_number = pages_number
            if self.form_result['release_date'] is not None:
                book.release_date = date(self.form_result['release_date'], 1, 1)
            if self.form_result['delete_logo']:
                book.logo = None
            elif self.form_result['logo'] is not None and self.form_result['logo'] != '':
                book.logo = self.form_result['logo'].file.read()
            book.location = self.form_result['location']
            meta.Session.commit()
            h.flash(_('Book was updated succesfully'))
            redirect(url(controller='books', action='show', id=book.id))

    def logo(self, id, width=None, height=None):
        return serve_logo('book', int(id), width=width, height=height)
