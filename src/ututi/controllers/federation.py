import cgi

from openid.consumer import consumer
from openid.consumer.consumer import Consumer, DiscoveryFailure
from openid.extensions import ax
import facebook
from xml.sax.saxutils import quoteattr

from pylons import request, url, session, config
from pylons.controllers.util import redirect
from pylons import tmpl_context as c
from pylons.i18n import _

from ututi.model.users import User
from ututi.model import meta
from ututi.lib.invitations import bind_group_invitations
from ututi.lib.security import sign_in_user
from ututi.lib.base import BaseController
import ututi.lib.helpers as h


class FederationMixin(object):

    def _bind_user(self, user, flash=True):
        """Bind user to FB/Google account (retrieve info from session)."""
        if session.get('confirmed_openid'):
            if User.get_byopenid(session['confirmed_openid']):
                # This rarely happens, but we have to check to avoid an error.
                if flash:
                    h.flash(_('This Google account is already linked to another Ututi account.'))
                return
            user.openid = session['confirmed_openid']
            if flash:
                h.flash(_('Your Google account has been associated with your Ututi account.'))
        elif session.get('confirmed_facebook_id'):
            if User.get_byfbid(session['confirmed_facebook_id']):
                # This rarely happens, but we have to check to avoid an error.
                if flash:
                    h.flash(_('This Facebook account is already linked to another Ututi account.'))
                return
            user.facebook_id = int(session['confirmed_facebook_id'])
            user.update_logo_from_facebook()
            if flash:
                h.flash(_('Your Facebook account has been associated with your Ututi account.'))


class FederationController(BaseController, FederationMixin):

    def google_login(self):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)
        GOOGLE_OPENID = 'https://www.google.com/accounts/o8/id'
        openid = GOOGLE_OPENID
        try:
            authrequest = cons.begin(openid)
        except DiscoveryFailure:
            h.flash(_('Authentication failed, please try again.'))
            redirect(c.came_from or url(controller='home', action='index'))

        ax_req = ax.FetchRequest()
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/first',
                               alias='firstname', required=True))
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/last',
                               alias='lastname', required=True))
        ax_req.add(ax.AttrInfo('http://schema.openid.net/contact/email',
                               alias='email', required=True))
        authrequest.addExtension(ax_req)

        kargs = self._auth_args()

        redirecturl = authrequest.redirectURL(
            url('frontpage', qualified=True),
            return_to=url(controller='federation', action='google_verify',
                          qualified=True, **kargs))

        session['openid_session'] = openid_session
        session.save()
        redirect(redirecturl)

    def _auth_args(self):
        """Return a dict of arguments to pass through FB/Google auth."""
        kargs = dict()
        if c.came_from:
            kargs['came_from'] = c.came_from
        invitation_hash = request.params.get('invitation_hash')
        if invitation_hash:
            kargs['invitation_hash'] = invitation_hash
        return kargs

    def _facebook_name_and_email(self, facebook_id, fb_access_token):
        graph = facebook.GraphAPI(fb_access_token)
        user_profile = graph.get_object("me")
        name = user_profile.get('name', '')
        email = user_profile.get('email', '')
        return name, email

    def google_verify(self):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)
        info = cons.complete(request.params,
                          url('google_verify', qualified=True))
        display_identifier = info.getDisplayIdentifier()

        if info.status == consumer.SUCCESS:
            identity_url = info.identity_url
            if 'linking_to_user' in session:
                user = User.get_byid(session.pop('linking_to_user'))
                if not User.get_byopenid(identity_url):
                    user.openid = identity_url
                    meta.Session.commit()
                    h.flash(_('Linked to Google account.'))
                else:
                    h.flash(_('This Google account is already linked to another Ututi account.'))
                redirect(url(controller='profile', action='login_settings'))
            name = '%s %s' % (request.params.get('openid.ext1.value.firstname'),
                              request.params.get('openid.ext1.value.lastname'))
            email = request.params.get('openid.ext1.value.email')
            return self._try_to_login(name, email, google_id=identity_url)
        elif info.status == consumer.FAILURE and display_identifier:
            # In the case of failure, if info is non-None, it is the
            # URL that we were verifying. We include it in the error
            # message to help the user figure out what happened.
            fmt = _("Verification of %s failed: %s")
            message = fmt % (display_identifier, cgi.escape(info.message))
        elif info.status == consumer.CANCEL:
            message = _('Verification cancelled')
        elif info.status == consumer.SETUP_NEEDED:
            if info.setup_url:
                message = _('<a href=%s>Setup needed</a>') % (
                    quoteattr(info.setup_url),)
            else:
                # This means auth didn't succeed, but you're welcome to try
                # non-immediate mode.
                message = _('Setup needed')
        else:
            message = _('Authentication failed: %s') % info.message
            # TODO: log info.status and info.message
        h.flash(message)
        redirect(c.came_from or url(controller='federation', action='index'))

    def _try_to_login(self, name, email, google_id=None, facebook_id=None,
                           fb_access_token=None):
        assert bool(google_id) != bool(facebook_id)
        if google_id:
            user = User.get_byopenid(google_id)
        elif facebook_id:
            user = User.get_byfbid(facebook_id)

        if user is not None:
            # Existing user, log him in and proceed.
            if facebook_id and not user.logo:
                user.update_logo_from_facebook()
                meta.Session.commit()
            sign_in_user(user)
            redirect(c.came_from or url(controller='home', action='index'))
        else:
            # Facebook needs to be asked for the email separately.
            if facebook_id:
                name, email = self._facebook_name_and_email(facebook_id,
                                                            fb_access_token)
                if not email:
                    h.flash(_('Facebook did not provide your email address.'))
                    redirect(c.came_from or url(controller='home', action='index'))

            # This user has never logged in using FB/Google before.
            user = User.get_global(email)
            if user is None:
                h.flash(_('Login failed. Please login using your username and bind your account first.'))
                redirect(url(controller='home', action='login'))
            else:
                # Existing user logging in using FB/Google.
                if google_id:
                    h.flash(_('Your Google account "%s" has been linked to your existing Ututi account.') % email)
                    user.openid = google_id
                elif facebook_id:
                    h.flash(_('Your Facebook account "%s" has been linked to your existing Ututi account.') % email)
                    user.facebook_id = facebook_id
                    bind_group_invitations(user)
                    if not user.logo:
                        user.update_logo_from_facebook()

                meta.Session.commit()
                sign_in_user(user)
                redirect(c.came_from or url(controller='home', action='index'))

    def test_facebook_login(self):
        assert config.get('facebook.testing')
        self._facebook_name_and_email = lambda id, token: ('John Smith', 'john.smith@example.com')
        return self._try_to_login(None, None, facebook_id=0xfaceb006,
                                       fb_access_token=-42)

    def facebook_login(self):
        fb_user = facebook.get_user_from_cookie(request.cookies,
                         config['facebook.appid'], config['facebook.secret'])
        if fb_user:
            uid = fb_user['uid']
            return self._try_to_login(None, None, facebook_id=uid,
                                           fb_access_token=fb_user['access_token'])
        redirect(c.came_from or url(controller='home', action='index'))

    def facebook_bind_proxy(self):
        if c.user is not None:
            fb_user = facebook.get_user_from_cookie(request.cookies,
                             config['facebook.appid'], config['facebook.secret'])
            if not fb_user:
                h.flash(_("Failed to link Facebook account"))
            else:
                facebook_id = int(fb_user['uid'])
                if not User.get_byfbid(facebook_id):
                    c.user.facebook_id = facebook_id
                    c.user.update_logo_from_facebook()
                    meta.Session.commit()
                    h.flash(_("Linked to Facebook account."))
                else:
                    h.flash(_('This Facebook account is already linked to another Ututi account.'))

        redirect(c.redirect_to or url('frontpage'))
