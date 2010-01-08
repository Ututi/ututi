import re
from lxml.html.clean import Cleaner

from formencode import validators, Invalid
from pylons.i18n import _
from pylons import c

from ututi.model import meta, Email

from ututi.model import LocationTag

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
        'badTag': _(u"Location does not exist.")
        }

    def _to_python(self, value, state):
        return LocationTag.get_by_title(value)

    def validate_python(self, value, state):
        if value is None:
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

class UniqueEmail(validators.FancyValidator):

    messages = {
        'empty': _(u"Enter a valid email."),
        'non_unique': _(u"The email already exists."),
        }

    def validate_python(self, value, state):
        if value == '':
            raise Invalid(self.message("empty", state), value, state)
        else:
            existing = meta.Session.query(Email).filter_by(email=value.strip().lower()).first()
            id = c.user.id if c.user is not None else 0
            if existing is not None and existing.user.id != id:
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

