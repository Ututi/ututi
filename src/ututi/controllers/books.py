import logging


from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, htmlfill
#from pylons import tmpl_context as c, request, url
#from routes.util import url_for

from pylons.i18n import _

from ututi.lib.base import BaseController, render, render_lang, u_cache

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

class BooksController(BaseController):

    def index(self):
        return render('books/index.mako')

    def _add_form(self):
        return render('books/add.mako')

    def add(self):
        return self._add_form()
