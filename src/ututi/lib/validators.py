import re

from os.path import splitext

from webob.multidict import UnicodeMultiDict
from decorator import decorator
from lxml.html.clean import Cleaner

from formencode import validators, Invalid, htmlfill, variabledecode
import formencode
from pylons.i18n import _
from pylons import config, tmpl_context as c

from pylons.decorators import PylonsFormEncodeState
from pylons.decorators import validate as old_validate

from ututi.model import GroupCoupon
from ututi.model import meta, Email
from ututi.model import Subject, Group, ContentItem, LocationTag


def u_error_formatter(error):
    return '<div class="error-container"><span class="error-message">%s</span></div>\n' % (
        htmlfill.html_quote(error))


def validate(schema=None, validators=None, form=None, variable_decode=False,
             dict_char='.', list_char='-', post_only=True, state=None,
             on_get=False, **htmlfill_kwargs):
    htmlfill_kwargs['error_formatters']= {'default' : u_error_formatter}
    return old_validate(schema=schema, validators=validators, form=form,
                        variable_decode=variable_decode, dict_char=dict_char,
                        list_char=list_char, post_only=post_only, state=state,
                        on_get=on_get, **htmlfill_kwargs)


def html_cleanup(input):
    cleaner = Cleaner(
        scripts = True,
        javascript = True,
        comments = True,
        style = False,
        links = True,
        meta = True,
        page_structure = True,
        processing_instructions = True,
        embedded = False,
        frames = False,
        forms = True,
        annoying_tags = True,
        allow_tags = ['a', 'img', 'span', 'div', 'p', 'br', 'iframe', # for google cal
                      'strong', 'em', 'u', 'strike', 'blockquote', 'sub', 'sup',
                      'ul', 'ol', 'li', 'table', 'tdata', 'tr', 'th', 'td',
                      'h1', 'h2', 'h3', 'h4'],
        remove_unknown_tags = False,
        safe_attrs_only = True,
        host_whitelist = ['youtube.com', 'www.google.com'],
        whitelist_tags = ['iframe', 'embed', 'script', 'img']
        )
    sane = cleaner.clean_html("<div>%s</div>"%input)
    return sane[len('<div>'):-len('</div>')]


class HtmlSanitizeValidator(validators.FancyValidator):
    """A validator that makes sure the text submitted contains only allowed html elements.
    No validation takes place - the input is simply transformed by removing anything that should
    not be here."""

    def _to_python(self, value, state):
        return html_cleanup(value.strip())


class UserPasswordValidator(validators.FancyValidator):
    """ User's password checker for password change form. """
    messages = {
        'invalid': _(u"Invalid password"),
        }

    def validate_python(self, value, state):
        if not c.user.checkPassword(value.encode('utf-8')):
            raise Invalid(self.message('invalid', state), value, state)


class LocationTagsValidator(validators.FancyValidator):
    """A validator that tests if the specified location tags are correct."""

    messages = {
        'badTag': _(u"Location does not exist."),
        'empty': _(u"Please specify your university."),
        }

    _notfoundmarker = object()

    def _to_python(self, value, state):
        if not any(value):
            return None
        return LocationTag.get_by_title(value) or self._notfoundmarker

    def validate_python(self, value, state):
        if value is None and self.not_empty:
            raise Invalid(self.message('empty', state), value, state)
        elif value is self._notfoundmarker:
            raise Invalid(self.message('badTag', state), value, state)


class LocationIdValidator(validators.FormValidator):

    messages = {
        'duplicate': _(u"Such short title already exists, choose a different one."),
    }

    def validate_python(self, form_dict, state):
        old_location = LocationTag.get(form_dict.get('old_path', ''))
        # XXX test for id matching a tag
        title_short = form_dict['title_short']
        path = old_location.path
        if len(path) > 0:
            del(path[-1])
        path.append(title_short)
        location = LocationTag.get(path)

        if location is not None and not location is old_location:
            raise Invalid(self.message('duplicate', state),
                          form_dict, state,
                          error_dict={'title_short' : Invalid(self.message('duplicate', state), form_dict, state)})


class PhoneNumberValidator(validators.FancyValidator):
    """A validator for Lithuanian phone numbers."""

    messages = {
        'invalid': _(u"Invalid phone number; use the format +37069912345"),
        'tooLong': _(u"Phone number too long; use the format +37069912345"),
        'tooShort': _(u"Phone number too short; use the format +37069912345"),
        'empty': _("The field may not be left empty.")
        }

    def _to_python(self, value, state):
        if not value.strip():
            if self.not_empty:
                raise Invalid(self.message('empty', state), value, state)
            else:
                return None
        s = re.sub(r'[^\d\+]', '', value) # strip away all non-numeric chars.
        if config.get('tpl_lang', 'lt') == 'lt':
            if s.startswith('8'):
                s = '+370' + s[1:]
            if not s.startswith('+370'):
                raise Invalid(self.message('invalid', state), value, state)
        elif config.get('tpl_lang') == 'pl':
            if not s.startswith('+48'):
                raise Invalid(self.message('invalid', state), value, state)

        if len(s) < 12:
            raise Invalid(self.message('tooShort', state), value, state)
        if len(s) > 12:
            raise Invalid(self.message('tooLong', state), value, state)
        if s.count('+') != 1:
            raise Invalid(self.message('invalid', state), value, state)
        return s


class InURLValidator(validators.FancyValidator):
    """ A validator for strings that appear in urls"""
    messages = {
        'badId': _(u"The field may only contain letters, numbers and the characters + - _"),
        'empty': _("The field may not be left empty.")
        }

    def validate_python(self, value, state):
        if value == '':
            raise Invalid(self.message('empty', state), value, state)

        valueRE = re.compile("^[\w+-]+$", re.I)
        if not valueRE.search(value):
            raise Invalid(self.message('badId', state), value, state)


class ShortTitleValidator(validators.FancyValidator):
    """ A validator for location tag short titles. """
    messages = {
        'badId': _(u"The field may only contain letters, numbers and the characters + - _"),
        'empty': _("The field may not be left empty.")
        }

    def validate_python(self, value, state):
        if value == '':
            raise Invalid(self.message('empty', state), value, state)

        valueRE = re.compile("^[\w+-]+$", re.I | re.UNICODE)
        if not valueRE.search(value):
            raise Invalid(self.message('badId', state), value, state)


class TagsValidator(validators.FormValidator):

    messages = {
        'too_long': _(u"The tag is too long."),
    }

    def validate_python(self, form_dict, state):
        tags = form_dict.get('tags', '')
        tags_js = form_dict.get('tagsitem', [])

        if tags_js != []:
            for tag in tags_js:
                if len(tag.strip()) >= 250:
                    raise Invalid(self.message('too_long', state),
                                  form_dict, state,
                                  error_dict={'tags' : Invalid(self.message('too_long', state), form_dict, state)})
        elif tags != '':
            for tag in tags.split(','):
                if len(tag.strip()) >= 250:
                    raise Invalid(self.message('too_long', state),
                                  form_dict, state,
                                  error_dict={'tags' : Invalid(self.message('too_long', state), form_dict, state)})

class TranslatedEmailValidator(validators.Email):
    messages = {
        'empty': _('Please enter an email address'),
        'noAt': _('An email address must contain a single @'),
        'badUsername': _('The username portion of the email address is invalid (the portion before the @: %(username)s)'),
        'socketError': _('An error occured when trying to connect to the server: %(error)s'),
        'badDomain': _('The domain portion of the email address is invalid (the portion after the @: %(domain)s)'),
        'domainDoesNotExist': _('The domain of the email address does not exist (the portion after the @: %(domain)s)'),
        'non_unique': _(u"The email already exists."),
    }

class UniqueEmail(validators.FancyValidator):

    messages = {
        'empty': _(u"Enter a valid email."),
        'non_unique': _(u"The email already exists."),
        }

    def __init__(self, *args, **kw):
        validators.FancyValidator.__init__(self, *args, **kw)
        self.completelyUnique = kw.get('completelyUnique', False)

    def validate_python(self, value, state):
        if value == '':
            raise Invalid(self.message("empty", state), value, state)
        else:
            existing = meta.Session.query(Email).filter_by(email=value.strip().lower()).first()
            id = c.user.id if c.user is not None else 0
            if existing is not None:
                if self.completelyUnique or existing.user.id != id:
                    raise Invalid(self.message("non_unique", state), value, state)


def manual_validate(schema, **state_kwargs):
    """Validate a formencode schema.
    Works similar to the @validate decorator. On success return a dictionary
    of parameters from request.params. On failure throws a formencode.Invalid
    exception."""
    # Create a state object if requested
    if state_kwargs:
        state = State(**state_kwargs)
    else:
       state = None

    # In case of validation errors an exception is thrown. This needs to
    # be caught elsewhere.
    from pylons import request
    return schema.to_python(request.params, state)

class ParentIdValidator(validators.FancyValidator):
    """
    A validator that determines if the id passed in references a Subject or a Group.
    Numeric ids as well as path fragments are allowed:
    - subject/vu/mif/subject_id for subjects
    - group/group_id for groups
    - 123 for either.
    """

    messages = {
        'badId': _(u"Id does not reference a group or a subject.")
        }

    def _to_python(self, value, state):
        obj = None
        # check if this is a plain numeric id
        try:
            num_id = int(value)
            obj = ContentItem.get(num_id)
        except ValueError:
            pass

        # check if the id is a path to a subject
        if obj is None and value.startswith('subject'):
            path = value.split('/')[1:]
            location = LocationTag.get(path[:-1])
            obj = Subject.get(location, path.pop())

        # check if the object is a group
        if obj is None and value.startswith('group'):
            id = value.split('/')
            obj = Group.get(id.pop())

        return obj

    def validate_python(self, value, state):
        if value is None or not isinstance(value, (Group, Subject)):
            raise Invalid(self.message('badId', state), value, state)

class FileUploadTypeValidator(validators.FancyValidator):
    """ A validator to check uploaded file types."""

    __unpackargs__ = ('allowed_types')

    messages = {
        'bad_type': _(u"Bad file type, only files of the types '%(allowed)s' are supported.")
        }

    def validate_python(self, value, state):
        if value is not None:
            if splitext(value.filename)[1].lower() not in self.allowed_types:
                raise Invalid(self.message('bad_type', state, allowed=', '.join(self.allowed_types)), value, state)

class GroupCouponValidator(validators.FancyValidator):
    """ Validate Group Coupon codes. Check for both collisions (creation) and existance (usage)."""
    messages = {
        'duplicate': _(u"Such coupon code already exists, choose a different one."),
        'not_exist': _(u"Such a coupon code does not exist.")
    }

    def __init__(self, check_collision=True, **kwargs):
        self.check_collision = check_collision
        validators.FancyValidator.__init__(self, **kwargs)

    def validate_python(self, value, state):
        coupon = GroupCoupon.get(value)
        error = None
        if coupon is not None and self.check_collision:
            error = 'duplicate'
        elif coupon is None and not self.check_collision:
            error = 'not_exist'
        if error is not None:
            raise Invalid(self.message(error, state), value, state)

class CommaSeparatedListValidator(validators.FancyValidator):
    """A validator splits form field value for further validation,
    used for chaining comma separated list validation (e.g. emails)."""

    messages = { 'empty': _(u"Please enter at least one value.") }

    def _to_python(self, value, state):
        print value
        if not value:
            raise Invalid(self.message('empty', state), value, state)

        from string import strip

        separated = filter(bool, map(strip, value.split(',')))
        if len(separated) == 0:
            raise Invalid(self.message('empty', state), value, state)

        return separated

def js_validate(schema=None, validators=None, form=None, variable_decode=False,
             dict_char='.', list_char='-', post_only=True, state=None,
             on_get=False, ignore_request=False, defaults=None, **htmlfill_kwargs):
    """Validate input either for a FormEncode schema, or individual
    validators

    Given a form schema or dict of validators, validate will attempt to
    validate the schema or validator list.

    If validation was successful, the valid result dict will be saved
    as ``self.form_result``. Otherwise, the action will be re-run as if
    it was a GET, and the output will be filled by FormEncode's
    htmlfill to fill in the form field errors.

    ``schema``
        Refers to a FormEncode Schema object to use during validation.
    ``form``
        Method used to display the form, which will be used to get the
        HTML representation of the form for error filling.
    ``variable_decode``
        Boolean to indicate whether FormEncode's variable decode
        function should be run on the form input before validation.
    ``dict_char``
        Passed through to FormEncode. Toggles the form field naming
        scheme used to determine what is used to represent a dict. This
        option is only applicable when used with variable_decode=True.
    ``list_char``
        Passed through to FormEncode. Toggles the form field naming
        scheme used to determine what is used to represent a list. This
        option is only applicable when used with variable_decode=True.
    ``post_only``
        Boolean that indicates whether or not GET (query) variables
        should be included during validation.

        .. warning::
            ``post_only`` applies to *where* the arguments to be
            validated come from. It does *not* restrict the form to
            only working with post, merely only checking POST vars.
    ``state``
        Passed through to FormEncode for use in validators that utilize
        a state object.
    ``on_get``
        Whether to validate on GET requests. By default only POST
        requests are validated.

    Example::

        class SomeController(BaseController):

            def create(self, id):
                return render('/myform.mako')

            @validate(schema=model.forms.myshema(), form='create')
            def update(self, id):
                # Do something with self.form_result
                pass

    """
    if state is None:
        state = PylonsFormEncodeState
    def wrapper(func, self, *args, **kwargs):
        """Decorator Wrapper function"""
        request = self._py_object.request
        errors = {}

        # Skip the validation if on_get is False and its a GET
        if not on_get and request.environ['REQUEST_METHOD'] == 'GET':
            return func(self, *args, **kwargs)

        # If they want post args only, use just the post args
        if post_only:
            params = request.POST
        else:
            params = request.params

        is_unicode_params = isinstance(params, UnicodeMultiDict)
        params = params.mixed()
        if variable_decode:
            decoded = variabledecode.variable_decode(params, dict_char,
                                                     list_char)
        else:
            decoded = params

        if schema:
            try:
                self.form_result = schema.to_python(decoded, state)
            except formencode.Invalid, e:
                errors = e.unpack_errors(variable_decode, dict_char, list_char)
        if validators:
            if isinstance(validators, dict):
                if not hasattr(self, 'form_result'):
                    self.form_result = {}
                for field, validator in validators.iteritems():
                    try:
                        self.form_result[field] = \
                            validator.to_python(decoded.get(field), state)
                    except formencode.Invalid, error:
                        errors[field] = error

        if errors:
            import simplejson
            output = {}
            output['success'] = False
            output['errors'] = errors
            return simplejson.dumps(output)
        return func(self, *args, **kwargs)

    return decorator(wrapper)

