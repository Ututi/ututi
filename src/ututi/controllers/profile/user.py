from formencode.api import Invalid

from pylons import request, tmpl_context as c, url
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect

from pylons.i18n import _

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.security import ActionProtector
from ututi.lib.forms import validate
from ututi.lib import sms
from ututi.lib.validators import manual_validate

from ututi.model import meta
from ututi.controllers.profile.base import ProfileControllerBase
from ututi.controllers.profile.validators import  PhoneConfirmationForm, PhoneForm

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

    @ActionProtector("user")
    def js_update_phone(self):
        try:
            fields = manual_validate(PhoneForm)
            c.user.phone_number = fields.get('phone_number', None)
            c.user.phone_confirmed = False
            if c.user.phone_number:
                sms.confirmation_request(c.user)
            meta.Session.commit()
            return render_mako_def('/profile/home_base.mako', 'phone_confirmation_nag')
        except Invalid:
            return ''

    @ActionProtector("user")
    @validate(schema=PhoneConfirmationForm, form='home')
    def confirm_phone(self):
        c.user.location = self.form_result.get('phone_confirmation_key', None)
        meta.Session.commit()
        h.flash(_('Your phone number has been confirmed.'))
        redirect(url(controller='profile', action='home'))

    @ActionProtector("user")
    def js_confirm_phone(self):
        key = request.params.get('phone_confirmation_key')
        if key.strip() != c.user.phone_confirmation_key.strip():
            return ''
        c.user.confirm_phone_number()
        meta.Session.commit()
        return render_mako_def('/profile/home_base.mako', 'phone_confirmed')

