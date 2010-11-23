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
from sqlalchemy.sql import func
from sqlalchemy.sql.expression import and_


from formencode.api import Invalid

from pylons.controllers.util import redirect
from pylons.i18n import _

from ututi.controllers.group import FileUploadTypeValidator
from ututi.model import LocationTag
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


class BookValidator(validators.FormValidator):
    """
    Validate the universal message post form.
    Check if the recipient's id has been specified in the js field, if not,
    check if enough text has been input to identify the recipient.
    """
    messages = {
        'invalid_science_type': _(u"Specify correct science type."),
        'invalid_book_department': _(u"Specify correct book department."),
        'no_location_specified': _(u"Specify correct location."),
        'no_type_specified': _(u"Specify book type."),
        'no_science_type_specified': _(u"Specify science type."),
        'wrong_science_type':  _(u"Wrong science type specified."),
        'no_city_specified': _(u"Specify city."),
        'no_school_grade_specified': _(u"Please specify school grade"),
    }

    def validate_python(self, form_dict, state):
        try:
            department_id = int(form_dict['department_id'])
        except ValueError:
            raise Invalid(self.message('invalid_book_department', state),
                          form_dict, state,
                          error_dict={'department_id': Invalid(self.message('invalid_book_department', state), form_dict, state)})

        if department_id is None:
            raise Invalid(self.message('invalid_book_department', state),
                          form_dict, state,
                          error_dict={'department_id': Invalid(self.message('invalid_book_department', state), form_dict, state)})
        form_dict['department_id'] = department_id

        try:
            city_id = int(form_dict['city'])
            form_dict['city'] = meta.Session.query(City).filter(City.id == city_id).one()
        except ValueError:
            raise Invalid(self.message('no_city_specified', state),
                          form_dict, state,
                          error_dict={'city': Invalid(self.message('no_city_specified', state), form_dict, state)})
        try:
            type_id = int(form_dict['type'])
            form_dict['type'] = meta.Session.query(BookType).filter(BookType.id == type_id).one()
        except ValueError:
            raise Invalid(self.message('no_type_specified', state),
                          form_dict, state,
                          error_dict={'type': Invalid(self.message('no_type_specified', state), form_dict, state)})

        if form_dict['department_id'] == Book.department['university']:
            form_dict['science_type'] = form_dict['university_science_type']
            if form_dict['location'] is None:
                raise Invalid(self.message('no_location_specified', state),
                          form_dict, state,
                          error_dict={'location': Invalid(self.message('no_location_specified', state), form_dict, state)})
            form_dict['school_grade'] = None
        elif form_dict['department_id'] == Book.department['school']:
            form_dict['science_type'] = form_dict['school_science_type']
            try:
                school_grade_id = int(form_dict['school_grade'])
                form_dict['school_grade'] = meta.Session.query(SchoolGrade).filter(SchoolGrade.id == school_grade_id).one()
            except ValueError:
                raise Invalid(self.message('no_school_grade_specified', state),
                          form_dict, state,
                          error_dict={'school_grade': Invalid(self.message('no_school_grade_specified', state), form_dict, state)})
            form_dict['location'] = None
        elif form_dict['department_id'] == Book.department['other']:
            form_dict['science_type'] = form_dict['other_science_type']
            form_dict['location'] = None
            form_dict['school_grade'] = None

        try:
            science_type_id = int(form_dict['science_type'])
            form_dict['science_type'] = meta.Session.query(ScienceType).filter(ScienceType.id == science_type_id).one()
        except ValueError:
            raise Invalid(self.message('no_science_type_specified', state),
                          form_dict, state,
                          error_dict={'science_type': Invalid(self.message('no_science_type_specified', state), form_dict, state)})
        del form_dict['university_science_type']
        del form_dict['school_science_type']
        del form_dict['other_science_type']


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
    show_phone = validators.Bool()
    delete_logo = validators.Bool()
    chained_validators = [BookValidator()]

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
        self._load_science_types()

    def _load_science_types(self):
        c.university_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id==Book.department["university"]).all()
        c.school_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id==Book.department['school']).all()
        c.other_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id==Book.department['other']).all()

    @validate(schema=BookForm, form='_add')
    @ActionProtector("user")
    def create(self):
        if hasattr(self, 'form_result'):
            title = self.form_result['title']
            price = self.form_result['price']
            book = Book(owner = c.user,
                        title = title,
                        price = price,
                        city = self.form_result['city'],
                        type = self.form_result['type'],
                        science_type = self.form_result['science_type'],
                        department_id = self.form_result['department_id'])
            book.author = self.form_result['author']
            book.description = self.form_result['description']
            if self.form_result['logo'] is not None and self.form_result['logo'] != '':
                book.logo = self.form_result['logo'].file.read()
            book.location = self.form_result['location']
            book.show_phone = self.form_result['show_phone']
            book.course = self.form_result['course']
            book.school_grade = self.form_result['school_grade']
            meta.Session.add(book)
            meta.Session.commit()
            h.flash(_('Book was added succesfully'))
            redirect(url(controller='books', action='show', id=book.id))

    @ActionProtector("user")
    def _add(self):
        self._load_defaults()
        c.current_science_types = meta.Session.query(ScienceType).all()
        return render('books/add.mako')

    def add(self):
        return self._add()

    def show(self, id):
        c.book = meta.Session.query(Book).filter(Book.id == id).one()
        return render('books/show.mako')

    def _edit(self):
        self._load_defaults()
        if c.book is not None and c.book != "" and c.book.department_id:
            c.current_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id == c.book.department_id).all()
        else:
            c.current_science_types = meta.Session.query(ScienceType).all()
        return render('books/edit.mako')

    @ActionProtector("user")
    def edit(self, id):
        c.book = meta.Session.query(Book).filter(Book.id == id).one()
        if c.book.owner != c.user:
            h.flash(_('Only owner of this book can do this action'))
            redirect(url(controller="books", action="index"))

        defaults = {
            'id': c.book.id,
            'title': c.book.title,
            'author': c.book.author,
            'show_phone': c.book.show_phone,
            'course': c.book.course,
            'school_grade': (c.book.school_grade.id if c.book.school_grade else None),
            c.book.departments[c.book.science_type.book_department_id] + '_science_type': c.book.science_type.id,
            'description': c.book.description,
            'price': c.book.price,
            'department_id': c.book.department_id,
            'city': c.book.city.id,
            'type': c.book.type.id
        }

        if c.book.location is not None:
            location = dict([('location-%d' % n, tag)
                             for n, tag in enumerate(c.book.location.hierarchy())])
        else:
            location = []

        defaults.update(location)

        self._load_defaults()
        if c.book.department_id:
            c.current_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id == c.book.department_id).all()
        else:
            c.current_science_types = meta.Session.query(ScienceType).all()
        return htmlfill.render(self._edit(), defaults=defaults)

    @validate(BookForm, form='_edit')
    @ActionProtector("user")
    def update(self):
        if hasattr(self, 'form_result'):
            book = meta.Session.query(Book).filter(Book.id == self.form_result['id']).one()
            book.title = self.form_result['title']
            book.price = self.form_result['price']
            book.city = self.form_result['city']
            book.type = self.form_result['type']
            book.science_type = self.form_result['science_type']
            book.department_id = self.form_result['department_id']
            book.author = self.form_result['author']
            book.description = self.form_result['description']
            if self.form_result['delete_logo'] == True:
                book.logo = None
            elif self.form_result['logo'] is not None and self.form_result['logo'] != '':
                book.logo = self.form_result['logo'].file.read()
            book.location = self.form_result['location']
            book.show_phone = self.form_result['show_phone']
            book.course = self.form_result['course']
            book.school_grade = self.form_result['school_grade']
            meta.Session.commit()
            h.flash(_('Book was updated succesfully'))
            redirect(url(controller='books', action='show', id=book.id))

    def logo(self, id, width=None, height=None):
        return serve_logo('book', int(id), width=width, height=height)

    def _catalog_form(self):
        c.book_types = meta.Session.query(BookType).all()
        return render('books/catalog.mako')

    def catalog(self, books_department=None, books_type_name=None, science_type_id=None, location_id=None, school_grade_id=None):
        books_department_id = None
        books_type_id = None
        school_grade = None
        science_type = None
        location = None
        #self._load_science_types()
        if books_department is not None:
            c.books_department = books_department
            books_department_id = Book.department[books_department]
        if books_type_name is not None:
            c.books_type = meta.Session.query(BookType).filter(func.lower(BookType.name)==books_type_name.replace("-", " ")).one()
        if location_id is not None:
            location = meta.Session.query(LocationTag).filter(LocationTag.id == location_id).one()
        if books_department_id is not None:
            c.current_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id == books_department_id)
            if books_department == "university":
                if location_id is not None and location is not None:
                    if location.parent is not None:
                        c.locations = meta.Session.query(LocationTag
                                                         ).filter(LocationTag.parent == location.parent
                                                                  ).order_by(LocationTag.title.asc())
                    else:
                        c.locations = meta.Session.query(LocationTag
                                                         ).filter(LocationTag.parent == location
                                                                  ).order_by(LocationTag.title.asc())
                else:
                    c.locations = meta.Session.query(LocationTag
                                                     ).filter(LocationTag.parent == None
                                                              ).order_by(LocationTag.title.asc())
            elif books_department == "school":
                c.school_grades = meta.Session.query(SchoolGrade)
                if school_grade_id is not None:
                    school_grade = meta.Session.query(SchoolGrade).filter(SchoolGrade.id == school_grade_id).one()
        if science_type_id is not None:
            c.science_type = meta.Session.query(ScienceType).filter(ScienceType.id == science_type_id).one()
        c.current_science_types = meta.Session.query(ScienceType).filter(ScienceType.book_department_id == books_department_id).all()
        #book filtering:
        books = meta.Session.query(Book)
        if location is not None:
            children = [child.id for child in location.flatten]
            books = books.filter(Book.location_id.in_(children))
        if books_department_id is not None:
            books = books.filter(Book.department_id == books_department_id)
        if school_grade is not None:
            books = books.filter(Book.school_grade == school_grade)
        if c.books_type is not None and c.books_type != "":
            books = books.filter(Book.type == c.books_type)
        if c.science_type is not None and c.science_type != "":
            books = books.filter(Book.science_type == c.science_type)
        c.books = self._make_pages(books)
        return self._catalog_form()
