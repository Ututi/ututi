import logging

from pylons import request
from pylons.controllers.util import abort

from ututi.lib.validators import validate, LogoUpload
from ututi.lib.image import serve_logo
from ututi.lib.base import BaseController

from ututi.model import meta
from ututi.model.theming import Theme

log = logging.getLogger(__name__)

def theme_action(method):
    def _theme_action(self, id):
        theme = Theme.get(id)

        if theme is None:
            abort(404)

        return method(self, theme)
    return _theme_action


# This controller should contain all logic that is needed for
# editing, updating and serving. The only problem is that we
# don't know where the actions should redirect, and what forms
# should be shown if validation fails.
#
# My idea would be to use request.referer and c.came_from for
# redirects, and independant theme forms if validation fails.

class ThemingController(BaseController):

    @theme_action
    @validate(LogoUpload)
    def update_header_logo(self, theme):
        if 'js' not in request.params:
            abort(404) # currently supports only js updated
        if hasattr(self, 'form_result'):
            logo = self.form_result['logo']
            if logo is not None:
                theme.header_logo = logo.file.read()
                meta.Session.commit()

        return 'OK'

    def header_logo(self, id, size=None):
        return serve_logo('theme', int(id), width=size, square=True, cache=False)
