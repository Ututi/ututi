import cgi
import facebook

from formencode import Schema, htmlfill, validators, variabledecode
from formencode.foreach import ForEach
from formencode.compound import Pipe

from pylons import tmpl_context as c, url, session, request, config
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.model import LocationTag
from ututi.lib.base import BaseController, render
from ututi.lib.image import serve_logo
from ututi.lib.invitations import bind_group_invitations
from ututi.lib.validators import validate, TranslatedEmailValidator, \
        FileUploadTypeValidator, SeparatedListValidator, CountryValidator, \
        AvailableEmailDomain, EmailDomainValidator
from ututi.lib.emails import teacher_registered_email
import ututi.lib.helpers as h

from ututi.model import meta
from ututi.model.users import User, UserRegistration
from ututi.model.i18n import Country

from openid.consumer import consumer
from openid.consumer.consumer import Consumer, DiscoveryFailure
from openid.extensions import ax

from xml.sax.saxutils import quoteattr

member_policies = [('RESTRICT_EMAIL',
                    _("Only people with confirmed university email can register")),
                   ('ALLOW_INVITES',
                    _("People with confirmed university email can register and other can be invited")),
                   ('PUBLIC',
                    _("Everyone can register to this university"))]

class PasswordOrFederatedLogin(validators.String):
    """Allow empty password if OpenID and/or FB are provided.
       Requires context c.registration to be set."""
    messages = {
        'empty': _(u"Please enter your password."),
        'tooShort': _(u"Password must be at least 5 characters long."),
    }

    def __init__(self):
        validators.String.__init__(self, min=5, strip=True)

    def to_python(self, value, state=None):
        self.not_empty = c.registration.openid is None and \
                         c.registration.facebook_id is None
        return super(validators.String, self).to_python(value, state)


class RegistrationPhotoValidator(FileUploadTypeValidator):
    """Allow empty logo field if user has logo set.
       Requires context c.registration to be set."""
    messages = {
       'empty': _(u"Please select your photo."),
       'bad_type': _(u"Please upload JPEG, PNG or GIF image.")
    }

    def __init__(self):
        allowed_types = ('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif')
        FileUploadTypeValidator.__init__(self, allowed_types=allowed_types)

    def to_python(self, value, state=None):
        self.not_empty = not c.registration.has_logo()
        return super(FileUploadTypeValidator, self).to_python(value, state)


class CodeResendForm(Schema):

    email = TranslatedEmailValidator(not_empty=True, strip=True)


class EmailApproveForm(Schema):

    hash = validators.String(min=32, max=32, strip=True)


class UniversityCreateForm(Schema):

    pre_validators = [variabledecode.NestedVariables()]

    msg = {'empty': _(u"Please enter university title.")}
    title = validators.String(not_empty=True, strip=True, messages=msg)

    country = CountryValidator(not_empty=True)

    msg = {'empty': _(u"Please enter university web site.")}
    site_url = validators.URL(not_empty=True, messages=msg)

    msg = {'missing': _(u"Please select logo."),
           'empty': _(u"Please select logo."),
           'bad_type': _(u"Please upload JPEG, PNG or GIF image.") }
    allowed_types = ('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif')
    logo = FileUploadTypeValidator(allowed_types=allowed_types, not_empty=True, messages=msg)

    msg = {'missing': _(u"Please specify member policy."),
           'invalid': _(u"Invalid policy selected."),
           'notIn': _(u"Invalid policy selected.") }
    member_policy = validators.OneOf(dict(member_policies).keys(), messages=msg)

    allowed_domains = ForEach(Pipe(validators.String(strip=True),
                                   EmailDomainValidator(),
                                   AvailableEmailDomain()))


class PersonalInfoForm(Schema):

    msg = {'empty': _(u"Please enter your full name.")}
    fullname = validators.String(not_empty=True, strip=True, messages=msg)
    password = PasswordOrFederatedLogin()


class AddPhotoForm(Schema):

    photo = RegistrationPhotoValidator()


class InviteFriendsForm(Schema):
    """There are two variants of the form, this schema handles both."""

    emails = Pipe(validators.String(),
                  SeparatedListValidator(separators=','),
                  ForEach(validators.Email()))


def registration_action(method):
    def _registration_action(self, hash, *args):
        registration = UserRegistration.get_by_hash(hash)

        if registration is None or registration.completed:
            abort(404)

        c.registration = registration

        c.steps = [
            ('university_info', _("University information")),
            ('personal_info', _("Personal information")),
            ('add_photo', _("Add your photo")),
            ('invite_friends', _("Invite friends")),
        ]

        c.active_step = None

        return method(self, registration, *args)
    return _registration_action


class FederationMixin(object):

    @registration_action
    def link_google(self, registration):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)

        GOOGLE_OPENID = 'https://www.google.com/accounts/o8/id'
        try:
            authrequest = cons.begin(GOOGLE_OPENID)
        except DiscoveryFailure:
            h.flash(_('Authentication failed, please try again.'))
            redirect(registration.url(action='personal_info'))

        ax_req = ax.FetchRequest()
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/first',
                               alias='firstname', required=True))
        ax_req.add(ax.AttrInfo('http://axschema.org/namePerson/last',
                               alias='lastname', required=True))
        ax_req.add(ax.AttrInfo('http://schema.openid.net/contact/email',
                               alias='email', required=True))
        authrequest.addExtension(ax_req)

        session['openid_session'] = openid_session
        session.save()

        realm = url(controller='home', action='index', qualified=True)
        return_to = registration.url(action='google_verify', qualified=True)

        redirect(authrequest.redirectURL(realm, return_to))

    @registration_action
    def google_verify(self, registration):
        openid_session = session.get("openid_session", {})
        openid_store = None # stateless
        cons = Consumer(openid_session, openid_store)

        current_url = registration.url(action='google_verify', qualified=True)
        info = cons.complete(request.params, current_url)

        display_identifier = info.getDisplayIdentifier()

        if info.status == consumer.SUCCESS:
            identity_url = info.identity_url
            if User.get_byopenid(identity_url, registration.location):
                message = _('This Google account is already linked to another Ututi account.')
            else:
                registration.openid = identity_url
                if not registration.fullname:
                    registration.fullname = '%s %s' % (
                        request.params.get('openid.ext1.value.firstname'),
                        request.params.get('openid.ext1.value.lastname'))
                email = request.params.get('openid.ext1.value.email')
                registration.openid_email = email
                meta.Session.commit()
                message = _('Linked to Google account.')
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
                message = _('<a href=%s>Setup needed</a>') % quoteattr(info.setup_url),
            else:
                # This means auth didn't succeed, but you're welcome to try
                # non-immediate mode.
                message = _('Setup needed')
        else:
            message = _('Authentication failed: %s') % info.message
            # TODO: log info.status and info.message

        h.flash(message)
        redirect(registration.url(action='personal_info'))

    @registration_action
    def unlink_google(self, registration):
        registration.openid = None
        meta.Session.commit()
        h.flash(_('Unlinked from Google account.'))
        redirect(registration.url(action='personal_info'))

    def _facebook_name_and_email(self, facebook_id, fb_access_token):
        graph = facebook.GraphAPI(fb_access_token)
        user_profile = graph.get_object("me")
        name = user_profile.get('name', '')
        email = user_profile.get('email', '')
        return name, email

    @registration_action
    def link_facebook(self, registration):
        fb_user = facebook.get_user_from_cookie(request.cookies,
                         config['facebook.appid'], config['facebook.secret'])
        if not fb_user:
            h.flash(_("Failed to link Facebook account"))
        else:
            facebook_id = int(fb_user['uid'])
            fb_access_token = fb_user['access_token']
            if not User.get_byfbid(facebook_id, registration.location):
                registration.facebook_id = facebook_id
                registration.update_logo_from_facebook()
                name, email = self._facebook_name_and_email(facebook_id, fb_access_token)
                if not registration.fullname:
                    registration.fullname = name
                registration.facebook_email = email

                meta.Session.commit()
                h.flash(_("Linked to Facebook account."))
            else:
                h.flash(_('This Facebook account is already linked to another user.'))
        redirect(registration.url(action='personal_info'))

    @registration_action
    def unlink_facebook(self, registration):
        registration.facebook_id = None
        meta.Session.commit()
        h.flash(_('Unlinked from Facebook account.'))
        redirect(registration.url(action='personal_info'))


class RegistrationController(BaseController, FederationMixin):

    @validate(schema=CodeResendForm(), form='resend_code')
    def resend_code(self):
        if not hasattr(self, 'form_result'):
            abort(404)

        email = self.form_result['email']
        registration = UserRegistration.get_by_email(email)
        if registration is None:
            abort(404)
        else:
            c.email = email
            registration.send_confirmation_email()
            h.flash(_("Your confirmation code was resent."))
            return render('registration/email_approval.mako')

    @registration_action
    def confirm_email(self, registration):
        registration.email_confirmed = True
        meta.Session.commit()
        redirect(registration.url(action='university_info'))

    def confirm_fb(self):
        return render('registration/confirm_fb.mako')

    def land_fb(self):
        fb_user = facebook.get_user_from_cookie(request.cookies,
                         config['facebook.appid'], config['facebook.secret'])

        if not fb_user or 'uid' not in fb_user or 'access_token' not in fb_user:
            h.flash(_("Failed to link Facebook account"))
            redirect(url('frontpage'))

        facebook_id = int(fb_user['uid'])
        fb_access_token = fb_user['access_token']
        registration = UserRegistration.get_by_fbid(facebook_id)

        if registration is None:
            h.flash(_("Your invitation has expired."))
            redirect(url('frontpage'))

        name, email = self._facebook_name_and_email(facebook_id, fb_access_token)
        if not email:
            h.flash(_("Facebook did not provide your email address."))
            redirect(url('frontpage'))

        registration.fullname = name
        registration.email = registration.facebook_email = email
        registration.email_confirmed = True
        registration.update_logo_from_facebook()
        meta.Session.commit()

        redirect(registration.url(action='university_info'))

    def _location_user_stats(self, location, display_count):
        ids = [loc.id for loc in location.flatten]
        user_count = meta.Session.query(User)\
                .filter(User.location_id.in_(ids)).count()
        users = meta.Session.query(User)\
                .filter(User.location_id.in_(ids))\
                .filter(User.raw_logo != None)\
                .order_by(User.accepted_terms.desc())\
                .limit(display_count).all()
        if len(users) < display_count:
            users.extend(meta.Session.query(User)\
                .filter(User.location_id.in_(ids))\
                .filter(User.raw_logo == None)\
                .order_by(User.accepted_terms.desc())\
                .limit(display_count - len(users)).all())

        return user_count, users

    @registration_action
    def university_info(self, registration):
        if registration.location is None:
            redirect(registration.url(action='university_create'))

        # get some statistics about this university
        c.user_count, c.users = \
            self._location_user_stats(registration.location, 14)

        c.active_step = 'university_info'
        return render('registration/university_info.mako')

    def _university_create_form(self):
        countries = meta.Session.query(Country).order_by(Country.name.asc()).all()
        c.countries = [('', _("(Select country from list)"))] + \
                [(country.id, country.name) for country in countries]

        global member_policies
        c.policies = member_policies
        c.active_step = 'university_info'
        c.max_allowed_domains = 50
        c.user_domain = c.registration.email.split('@')[1]
        return render('registration/university_create.mako')

    @registration_action
    @validate(schema=UniversityCreateForm(), form='_university_create_form', variable_decode=True)
    def university_create(self, registration):
        if not hasattr(self, 'form_result'):
            _, _, domain_name = c.registration.email.rpartition('@')
            defaults = {
                'allowed_domains-0': domain_name,
                'site_url': 'http://' + domain_name,
            }
            # try to guess country as well
            _, _, tld = domain_name.rpartition('.')
            country = meta.Session.query(Country)\
                    .filter(Country.locale.endswith(tld.upper())).first()
            if country is not None:
                defaults['country'] = country.id
            return htmlfill.render(self._university_create_form(), defaults=defaults)

        registration.university_title = self.form_result['title']
        registration.university_site_url = self.form_result['site_url']
        registration.university_logo = self.form_result['logo'].file.read()
        registration.university_member_policy = self.form_result['member_policy']
        allowed_domains = filter(bool, self.form_result['allowed_domains'])
        registration.university_allowed_domains = ','.join(allowed_domains)
        meta.Session.commit()
        redirect(registration.url(action='personal_info'))

    def _personal_info_form(self):
        c.active_step = 'personal_info'
        return render('registration/personal_info.mako')

    @registration_action
    @validate(schema=PersonalInfoForm(), form='_personal_info_form')
    def personal_info(self, registration):
        if hasattr(self, 'form_result'):
            registration.fullname = self.form_result['fullname']
            registration.update_password(self.form_result['password'])
            meta.Session.commit()
            redirect(registration.url(action='add_photo'))

        defaults = {
            'fullname': registration.fullname,
        }
        return htmlfill.render(self._personal_info_form(), defaults=defaults)

    def _add_photo_form(self):
        c.active_step = 'add_photo'
        return render('registration/add_photo.mako')

    @registration_action
    @validate(schema=AddPhotoForm(), form='_add_photo_form')
    def add_photo(self, registration):
        if hasattr(self, 'form_result'):
            photo = self.form_result['photo']
            if photo is not None:
                registration.logo = photo.file.read()
                meta.Session.commit()
            if request.params.has_key('js'):
                return 'OK'
            else:
                redirect(registration.url(action='invite_friends'))

        return htmlfill.render(self._add_photo_form())

    def _invite_friends_form(self):
        c.active_step = 'invite_friends'
        return render('registration/invite_friends.mako')

    @registration_action
    @validate(schema=InviteFriendsForm(), form='_invite_friends_form', variable_decode=True)
    def invite_friends(self, registration):
        if hasattr(self, 'form_result'):
            emails = self.form_result['emails']
            registration.invited_emails = ','.join(filter(bool, emails))
            meta.Session.commit()
            redirect(registration.url(action='finish'))

        return htmlfill.render(self._invite_friends_form())

    @registration_action
    def invite_friends_fb(self, registration):
        # handle facebook callback
        ids = request.params.get('ids[]')
        if ids:
            registration.invited_fb_ids = ids
            meta.Session.commit()
            redirect(registration.url(action='finish'))

        # render page
        fb_user = facebook.get_user_from_cookie(request.cookies,
                      config['facebook.appid'], config['facebook.secret'])
        c.has_facebook = fb_user is not None
        if c.has_facebook:
            try:
                graph = facebook.GraphAPI(fb_user['access_token'])
                friends = graph.get_object("me/friends")
                friend_ids = [f['id'] for f in friends['data']]
                friend_users = meta.Session.query(User)\
                        .filter(User.facebook_id.in_(friend_ids))\
                        .filter(User.location == registration.location).all()
                c.exclude_ids = ','.join(str(u.facebook_id) for u in friend_users)
            except facebook.GraphAPIError:
                c.has_facebook = False

        c.active_step = 'invite_friends'
        return render('registration/invite_friends_fb.mako')

    @registration_action
    def finish(self, registration):
        from ututi.lib.security import sign_in_user
        if not registration.location:
            # If there is a university with same title we will use it.
            location = LocationTag.get_by_title(registration.university_title)
            if not location:
                location =  registration._create_university()
            registration.location = location

        user = registration.create_user()
        bind_group_invitations(user)

        meta.Session.add(user)
        meta.Session.commit()
        # TODO: handle any integrity errors here

        registration.completed = True
        registration.process_invitations()
        meta.Session.commit()

        if user.is_teacher:
            teacher_registered_email(user)

        sign_in_user(user)
        redirect(url(controller='profile', action='register_welcome'))

    def logo(self, id, size):
        return serve_logo('registration', id, width=size, square=True,
                          default_img_path="public/img/user_default.png",
                          cache=False)
