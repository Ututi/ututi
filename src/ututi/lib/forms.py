import logging
from zope.cachedescriptors.property import Lazy
from webhelpers.html.builder import literal
from decorator import decorator

import formencode
from formencode import htmlfill, variabledecode

from pylons.decorators import PylonsFormEncodeState

from ututi.lib.validators import u_error_formatter

log = logging.getLogger(__name__)


def validate(schema=None, validators=None, form=None, variable_decode=False,
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
    htmlfill_kwargs['error_formatters']= {'default' : u_error_formatter}
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

        params = params.mixed()
        if variable_decode:
            log.debug("Running variable_decode on params")
            decoded = variabledecode.variable_decode(params, dict_char,
                                                     list_char)
        else:
            decoded = params

        if schema:
            log.debug("Validating against a schema")
            try:
                self.form_result = schema.to_python(decoded, state)
            except formencode.Invalid, e:
                errors = e.unpack_errors(variable_decode, dict_char, list_char)
        if validators:
            log.debug("Validating against provided validators")
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
            log.debug("Errors found in validation, parsing form with htmlfill "
                      "for errors")
            request.environ['REQUEST_METHOD'] = 'GET'
            self._py_object.tmpl_context.form_errors = errors

            # If there's no form supplied, just continue with the current
            # function call.
            if not form:
                return func(self, *args, **kwargs)

            request.environ['pylons.routes_dict']['action'] = form
            response = self._dispatch_call()
            # XXX: Legacy WSGIResponse support
            legacy_response = False
            if hasattr(response, 'content'):
                form_content = ''.join(response.content)
                legacy_response = True
            else:
                form_content = response
                response = self._py_object.response

            # If the form_content is an exception response, return it
            if hasattr(form_content, '_exception'):
                return form_content

            if ignore_request:
                params = {}

            if defaults is not None:
                default_values = defaults(self)
                default_values.update(params)
                params = default_values

            form_content = htmlfill.render(form_content, defaults=params,
                                           errors=errors, **htmlfill_kwargs)
            if legacy_response:
                # Let the Controller merge the legacy response
                response.content = form_content
                return response
            else:
                return form_content
        return func(self, *args, **kwargs)
    return decorator(wrapper)


class FormEncodeState(object):

    def __init__(self, request):
        self.request = request


def error_formatter(message):
    return '<div class="error-message">%s</div>' % message


class FormBase(object):

    def __init__(self, context, request):
        self.request = request
        self.context = context
        self.errors = {}

    def validate_schema(self, schema, variable_decode=True,
                        dict_char='.', list_char='-'):
        if variable_decode:
            log.debug("Running variable_decode on params")
            decoded = variabledecode.variable_decode(self.request.params, dict_char, list_char)

        errors = {}
        form_result = {}
        log.debug("Validating against a schema")
        try:
            form_result = schema.to_python(decoded,
                                           FormEncodeState(self.request))
        except formencode.Invalid, e:
            errors = e.unpack_errors(variable_decode, dict_char, list_char)

        if errors:
            log.debug("Errors found in validation, parsing form with htmlfill "
                      "for errors")
        return form_result, errors

    def work(self):
        if self.action in self.request.params:
            values, errors = self.validate
            if not errors:
                return self.apply(self.context, values)
            else:
                self.errors = errors

    def defaults(self):
        return {}

    def defaults_from_request(self, request):
        return request.params

    # XXX solving double validation using Lazy
    @Lazy
    def validate(self):
        return self.validate_schema(self.schema)

    def __call__(self, form_content):
        # Defaults can be given either in a dict or a callable
        defaults = self.defaults() if hasattr(self.defaults, '__call__') else self.defaults
        errors = {}
        if self.action in self.request.params:
            _, errors = self.validate
            defaults = self.defaults_from_request(self.request)

        return literal(htmlfill.render(form_content,
                               defaults=defaults,
                               auto_error_formatter=error_formatter,
                               errors=errors))


class Form(FormBase):
    """Class for one form views.

    To define a form do something like in __init__ of the view:

        >> self.form = Form(context, request,
        ..                  apply=self.apply,
        ..                  defaults=self.defaults,
        ..                  schema=FormSchema(),
        ..                  action='UPDATE')

    """

    def __init__(self, context, request, apply, schema, action, defaults=None):
        self.request = request
        self.context = context
        self.schema = schema
        self.apply = apply
        self.action = action

        if defaults is not None:
            self.defaults = defaults

