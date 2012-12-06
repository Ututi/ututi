from pylons import tmpl_context as c, url
from pylons.controllers.util import redirect

from pylons.i18n import _

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.security import ActionProtector
from ututi.lib.forms import validate

from ututi.model import meta
from ututi.controllers.profile.base import ProfileControllerBase
from ututi.controllers.profile.validators import PhoneForm

class UserProfileController(ProfileControllerBase):
    """A controller for the user's personal information and actions."""
    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        bcs = {
            'home':
            {'title': _("Home"),
             'link': url(controller='profile', action='home')},
            'feed':
            {'title': _("What's New?"),
             'link': url(controller='profile', action='feed')},
            'my_subjects':
            {'title': _("My subjects"),
             'link': url(controller='profile', action='my_subjects')},
            'subjects':
            {'title': _("Subjects"),
             'link': url(controller='profile', action='watch_subjects')}
            }
        if selected in bcs.keys():
            return bcs[selected]

    @ActionProtector("user")
    def home(self):
        if c.user.is_freshman():
            redirect(url(controller='profile', action='get_started'))
        else:
            redirect(url(controller='profile', action='feed'))

    @ActionProtector("user")
    def my_subjects(self):
        c.breadcrumbs.append(self._actions('my_subjects'))
        return render('/profile/my_subjects.mako')

    @ActionProtector("user")
    def register_welcome(self):
        c.welcome = True
        return render('/profile/get_started.mako')

    @ActionProtector("user")
    def get_started(self):
        return render('/profile/get_started.mako')

    @ActionProtector("user")
    @validate(schema=PhoneForm, form='home')
    def update_phone(self):
        c.user.location = self.form_result.get('phone_number', None)
        meta.Session.commit()
        h.flash(_('Your phone number has been updated.'))
        redirect(url(controller='profile', action='home'))
