import re
from lxml.html.clean import Cleaner

from formencode import validators, Invalid
from pylons.i18n import _

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
    """ A validator for strings that appear in urls (e.g. location tag short titles) """
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
