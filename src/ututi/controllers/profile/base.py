from datetime import datetime
import facebook

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import desc

from formencode import htmlfill, validators
from formencode.foreach import ForEach
from formencode.schema import Schema

from pylons import request, tmpl_context as c, url, config, session
from pylons.decorators import jsonify
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect

from pylons.i18n import _, ungettext

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.emails import email_confirmation_request, \
        send_registration_invitation, email_password_reset
from ututi.lib.events import event_types_grouped
from ututi.lib.fileview import FileViewMixin
from ututi.lib.security import ActionProtector
from ututi.lib.image import serve_logo
from ututi.lib.forms import validate
from ututi.lib.invitations import make_email_invitations, make_facebook_invitations
from ututi.lib.messaging import EmailMessage
from ututi.lib import gg, sms
from ututi.lib.validators import js_validate, LogoUpload

from ututi.model.events import Event
from ututi.model import meta, Email, User

from ututi.controllers.profile.validators import HideElementForm, \
    MultiRcptEmailForm, FriendsInvitationJSForm, ContactForm, \
    ProfileForm, PasswordChangeForm, DeleteMeForm
from ututi.controllers.profile.wall import UserWallMixin
from ututi.controllers.profile.subjects import WatchedSubjectsMixin
from ututi.controllers.search import SearchSubmit, SearchBaseController
from ututi.controllers.home import sign_in_user
from ututi.controllers.home import UniversityListMixin


class WallSettingsForm(Schema):
    allow_extra_fields = True
    filter_extra_fields = True
    events = ForEach(validators.String())

class ProfileControllerBase(SearchBaseController, UniversityListMixin, FileViewMixin, WatchedSubjectsMixin, UserWallMixin):

    def _actions(self, selected):
        raise NotImplementedError("This has to be implemented by the"
                                  " specific profile controller.")

    def _account_settings_tabs(self):
        return [
            {'title': _("Login"),
             'name': 'login',
             'link': url(controller='profile', action='login_settings')},
            {'title': _("News feed"),
             'name': 'wall',
             'link': url(controller='profile', action='wall_settings')},
            {'title': _("Notifications"),
             'name': 'notifications',
             'link': url(controller='profile', action='notification_settings')},
        ]

    def _edit_profile_tabs(self):
        return [
            {'title': _("General"),
             'name': 'general',
             'link': url(controller='profile', action='edit')},
            {'title': _("Contacts"),
             'name': 'contacts',
             'link': url(controller='profile', action='edit_contacts')},
        ]

    @ActionProtector("user")
    def index(self):
        raise NotImplementedError("This has to be implemented by the"
                                  " specific profile controller.")

    @ActionProtector("user")
    def home(self):
        raise NotImplementedError("This has to be implemented by the"
                                  " specific profile controller.")

    @ActionProtector("user")
    def register_welcome(self):
        raise NotImplementedError("This has to be implemented by the"
                                  " specific profile controller.")

    def __before__(self):
        if c.user is not None:
            c.breadcrumbs = [{'title': c.user.fullname, 'link': url(controller='profile', action='home')}]

    @ActionProtector("user")
    def events(self):
        c.events = meta.Session.query(Event)\
            .filter(Event.author_id == c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()
        return render('profile/events.mako')

    @ActionProtector("user")
    def browse(self):
        c.breadcrumbs = [{'title': _('Search'), 'link': url(controller='profile', action='browse')}]
        self._get_unis()

        c.obj_type = '*'
        if request.params.has_key('js'):
            return render_mako_def('/search/browse.mako', 'universities',
                                   unis=c.unis, ajax_url=url(controller='profile', action='browse'))

        return render('/profile/browse.mako')

    @ActionProtector("user")
    @validate(schema=SearchSubmit, form='index', post_only=False, on_get=True)
    def search(self):
        c.breadcrumbs = [{'title': _('Search'), 'link': url(controller='profile', action='browse')}]
        self._search()
        self._search_locations(self.form_result.get('text', ''))
        return render('/profile/search.mako')

    @ActionProtector("user")
    @validate(schema=SearchSubmit, form='index', post_only=False, on_get=True)
    def search_js(self):
        self._search()
        return render_mako_def('/search/index.mako','search_results', results=c.results, controller='profile', action='search_js')

    @ActionProtector("user")
    def feed(self):
        self._set_wall_variables(events_hidable=True)

        c.msg_recipients = [(m.group.id, m.group.title)
                            for m in c.user.memberships]

        c.file_recipients = [(m.group.id, m.group.title)
                             for m in c.user.memberships
                             if (m.group.has_file_area and
                                 m.group.upload_status != m.group.LIMIT_REACHED)]
        c.file_recipients.extend([(s.id, s.title) for s in c.user.all_watched_subjects])

        c.wiki_recipients =  [(subject.id, subject.title)
                              for subject in c.user.all_watched_subjects]

        for event in c.events:
            event['event_is_new'] = event.last_activity > c.user.last_seen_feed

        result = render('/profile/feed.mako')

        # Register new news feed visit.
        meta.Session.commit() # commit before that to avoid possible
                              # conflicts (on double refresh for
                              # example)
        c.user.last_seen_feed = datetime.utcnow()
        meta.Session.commit()

        return result

    ## settings pages

    @ActionProtector("user")
    def settings(self):
        # pick default settings tab
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    def login_settings(self):
        c.tabs = self._account_settings_tabs()
        c.current_tab = 'login'
        return render('/profile/settings_login.mako')

    def _wall_settings_form(self):
        c.event_types = event_types_grouped(Event.event_types())
        c.tabs = self._account_settings_tabs()
        c.current_tab = 'wall'
        return render('profile/settings_wall.mako')

    @ActionProtector("user")
    @validate(schema=WallSettingsForm, form='_wall_settings_form')
    def wall_settings(self):
        defaults = {
            'events': list(set(Event.event_types()) - \
                           set(c.user.ignored_events_list))
        }
        return htmlfill.render(self._wall_settings_form(),
                               defaults=defaults)

    @ActionProtector("user")
    @validate(schema=WallSettingsForm, form='_wall_settings_form')
    def update_wall_settings(self):
        if hasattr(self, 'form_result'):
            events = set(self.form_result.get('events', []))
            events = list(set(Event.event_types()) - events)
            c.user.update_ignored_events(events)
            meta.Session.commit()
            h.flash(_('Your wall settings have been updated.'))
        redirect(url(controller='profile', action='wall_settings'))

    @ActionProtector("user")
    def notification_settings(self):
        c.tabs = self._account_settings_tabs()
        c.current_tab = 'notifications'
        c.subjects = c.user.watched_subjects
        c.groups = c.user.groups
        return render('profile/settings_notifications.mako')

    def _edit_form_defaults(self):
        defaults = {
            'email': c.user.emails[0].email,
            'gadugadu_uin': c.user.gadugadu_uin,
            'gadugadu_get_news': c.user.gadugadu_get_news,
            'phone_number': c.user.phone_number,
            'fullname': c.user.fullname,
            'site_url': c.user.site_url,
            'description': c.user.description,
            'profile_is_public': c.user.profile_is_public,
            'email_is_public': c.user.email_is_public,
            'url_name': c.user.url_name,
        }
        # TODO Move this code to profile settings
        #if c.user.location is not None:
        #    for n, tag in enumerate(c.user.location.hierarchy()):
        #        defaults['location-%d' % n] = tag
        if c.user.is_teacher:
            additional = {
                'teacher_position': c.user.teacher_position,
                'work_address': c.user.work_address,
            }
            defaults.update(additional)

        return defaults

    def _edit_profile_form(self):
        c.tabs = self._edit_profile_tabs()
        c.current_tab = 'general'
        c.teachers_url = ''
        if c.user.location.teachers_url:
            c.teachers_url = c.user.location.teachers_url
        return render('profile/edit_profile.mako')

    @ActionProtector("user")
    def edit(self):
        return htmlfill.render(self._edit_profile_form(),
                               defaults=self._edit_form_defaults())

    @validate(ProfileForm, form='_edit_profile_form', defaults=_edit_form_defaults)
    @ActionProtector("user")
    def update(self):
        values = {
            'fullname': None,
            'description': None,
            'profile_is_public': None,
            'url_name': None,
            'teacher_position': None,
        }
        values.update(self.form_result)

        c.user.fullname = values['fullname']
        if values['description'] is not None:
            # this check is needed because description field
            # is currently reused as teacher's information and
            # is not displayed for teacher in this form.
            c.user.description = values['description']
        c.user.profile_is_public = bool(values['profile_is_public'])
        c.user.url_name = values['url_name']
        if c.user.is_teacher:
            c.user.profile_is_public = True # teacher profile always public
            c.user.teacher_position = values['teacher_position'] # additional teacher fields
        meta.Session.commit()
        h.flash(_('Your profile was updated.'))
        redirect(url(controller='profile', action='edit'))

    def _edit_contacts_form(self):
        c.tabs = self._edit_profile_tabs()
        c.current_tab ='contacts'
        return render('profile/edit_contacts.mako')

    @ActionProtector("user")
    def edit_contacts(self):
        return htmlfill.render(self._edit_contacts_form(),
                               defaults=self._edit_form_defaults())

    @ActionProtector("user")
    @validate(LogoUpload, form='edit_photo')
    def update_photo(self):
        if hasattr(self, 'form_result'):
            logo = self.form_result['logo']
            if logo is not None:
                c.user.logo = logo.file.read()
                meta.Session.commit()
                if 'js' not in request.params:
                    h.flash(_("Your photo successfully updated."))
            if 'js' in request.params:
                return 'OK'
        redirect(url(controller='profile', action='edit'))

    @ActionProtector("user")
    def remove_photo(self):
        c.user.logo = None
        meta.Session.commit()
        h.flash(_("Your photo was removed."))
        redirect(url(controller='profile', action='edit'))

    @ActionProtector("user")
    def link_google(self):
        session['linking_to_user'] = c.user.id
        session.save()
        redirect(url(controller='federation', action='google_login'))

    @ActionProtector("user")
    def unlink_google(self):
        c.user.openid = None
        meta.Session.commit()
        h.flash(_('Your Google account has been unlinked.'))
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    def link_facebook(self):
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
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    def unlink_facebook(self):
        c.user.facebook_id = None
        meta.Session.commit()
        h.flash(_('Your Facebook account has been unlinked.'))
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    @validate(PasswordChangeForm, form='login_settings', ignore_request=True)
    def change_password(self):
        if hasattr(self, 'form_result'):
            c.user.update_password(self.form_result['new_password'].encode('utf-8'))
            meta.Session.commit()
            h.flash(_('Your password has been changed!'))
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    @validate(DeleteMeForm, form='login_settings', ignore_request=True)
    def delete_my_account(self):
        if hasattr(self, 'form_result'):
                h.flash(_('Your account has been successfully removed!'))
                c.user.delete_user()
                meta.Session.commit()
                redirect(url(controller='home', action='logout'))
        redirect(url(controller='profile', action='login_settings'))

    @ActionProtector("user")
    def recover_password(self):
        if not c.user.recovery_key:
            c.user.gen_recovery_key()
        email_password_reset(c.user)
        meta.Session.commit()
        h.flash(_('Password recovery email sent to %(user_email)s. '
                  'Please check your inbox.') % {
                  'user_email': c.user.email.email
                  })
        redirect(url(controller='profile', action='login_settings'))

    @validate(LogoUpload)
    @ActionProtector("user")
    def logo_upload(self):
        if self.form_result['logo'] is not None:
            logo = self.form_result['logo']
            c.user.logo = logo.file.read()
            meta.Session.commit()
            return ''

    @ActionProtector("user")
    def confirm_emails(self):
        emails = request.POST.getall('email')
        for email in emails:
            email_confirmation_request(c.user, email)
        h.flash(_('Confirmation message sent. Please check your email.'))
        dest = request.POST.get('came_from', None)
        if dest is not None:
            redirect(dest.encode('utf-8'))
        else:
            redirect(url(controller='profile', action='edit_contacts'))

    def confirm_user_email(self, key):
        try:
            email = meta.Session.query(Email).filter_by(confirmation_key=key).one()
            email.confirmed = True
            email.confirmation_key = ''
            meta.Session.commit()
            h.flash(_("Your email %s has been confirmed, thanks." % email.email))
        except NoResultFound:
            h.flash(_("Could not confirm email: invalid confirmation key."))

        redirect(url(controller='profile', action='home'))

    @ActionProtector("user")
    def logo(self, width=None, height=None):
        return serve_logo('user', c.user.id, width=width, height=height,
                          default_img_path="public/img/user_default.png",
                          cache=False)

    @ActionProtector("user")
    def set_receive_email_each(self):
        if request.params.get('each') in ('day', 'hour', 'never'):
            c.user.receive_email_each = request.params.get('each')
            meta.Session.commit()
        if request.params.get('ajax'):
            return 'OK'
        redirect(url(controller='profile', action='notification_settings'))

    @validate(ContactForm, form='_edit_contacts_form', defaults=_edit_form_defaults)
    @ActionProtector("user")
    def update_contacts(self):
        # TODO: this should be refactored into separate actions
        if hasattr(self, 'form_result'):
            # site url
            c.user.site_url = self.form_result['site_url']

            # address and email visibility (teachers only)
            if c.user.is_teacher:
                c.user.work_address = self.form_result['work_address']
                c.user.email_is_public = 'email_is_public' in self.form_result

            if self.form_result['confirm_email']:
                h.flash(_('Confirmation message sent. Please check your email.'))
                email_confirmation_request(c.user, c.user.emails[0].email)
                redirect(url(controller='profile', action='edit_contacts'))

            # handle email
            email = self.form_result['email']
            confirmed = False
            if email != c.user.emails[0].email:
                # XXX Allow user to set default email if it already added as second.
                if len(c.user.emails) > 1:
                    if c.user.emails[1].email == email:
                        del c.user.emails[1]
                        meta.Session.commit()
                        confirmed = True

                c.user.emails[0].email = email
                c.user.emails[0].confirmed = confirmed
                email_confirmation_request(c.user, email)
                sign_in_user(c.user)

            # handle GG
            gadugadu_uin = self.form_result['gadugadu_uin']
            gadugadu_confirmation_key = self.form_result['gadugadu_confirmation_key']

            if self.form_result['resend_gadugadu_code']:
                gg.confirmation_request(c.user)
            elif gadugadu_uin != c.user.gadugadu_uin:
                c.user.gadugadu_uin = gadugadu_uin
                c.user.gadugadu_confirmed = False
                c.user.gadugadu_get_news = False
                if gadugadu_uin:
                    gg.confirmation_request(c.user)
            elif gadugadu_confirmation_key:
                c.user.gadugadu_confirmed = True
            else:
                c.user.gadugadu_get_news = self.form_result['gadugadu_get_news']

            # handle phone number
            phone_number = self.form_result['phone_number']
            phone_confirmation_key = self.form_result['phone_confirmation_key']

            if self.form_result['resend_phone_code']:
                sms.confirmation_request(c.user)
            elif phone_number != c.user.phone_number:
                c.user.phone_number = phone_number
                c.user.phone_confirmed = False
                if phone_number:
                    # new number
                    if c.user.is_teacher:
                        # don't asks confirmations from teachers
                        c.user.phone_confirmed = True
                    else:
                        sms.confirmation_request(c.user)
            elif phone_confirmation_key:
                c.user.confirm_phone_number()

        meta.Session.commit()
        h.flash(_('Your contact information was updated.'))
        redirect(url(controller='profile', action='edit_contacts'))

    @ActionProtector("user")
    def thank_you(self):
        return render('/profile/thank_you.mako')

    @ActionProtector("user")
    def no_thank_you(self):
        return render('/profile/no_thank_you.mako')

    def support(self):
        if not c.user:
            redirect(url(controller='home',
                         action='login',
                         came_from=url(controller='profile', action='support'),
                         context_type='support'))
        return render('/profile/support.mako')

    @ActionProtector("user")
    @validate(schema=HideElementForm)
    def js_hide_element(self):
        if hasattr(self, 'form_result') and self.form_result['type'] not in c.user.hidden_blocks.split(' '):
            c.user.hidden_blocks = "%s %s" % (c.user.hidden_blocks, self.form_result['type'])
            meta.Session.commit()

    @ActionProtector("root")
    def session_info(self):
        """ Display session values for testing purposes. """
        ret = ""
        items = session.items()
        items.sort()
        for key, value in items:
            ret += "%s => %s\n" % (key, value)
        return ret

    @js_validate(schema=MultiRcptEmailForm())
    @jsonify
    def send_email_message_js(self):
        if hasattr(self, 'form_result'):
            msg = EmailMessage(self.form_result['subject'],
                               self.form_result['message'],
                               sender=self.form_result['sender'],
                               force=True)
            for rcpt in self.form_result['recipients']:
                msg.send(rcpt)
            return {'success': True}

    def invite_friends_email(self):
        emails = request.POST.get('recipients')
        message = request.POST.get('message') # optional
        if emails:
            emails = emails.split(',')
            invites, invalid, already = \
                make_email_invitations(emails, c.user, c.user.location)
            meta.Session.commit()
            for invitee in invites:
                send_registration_invitation(invitee, c.user, message)

            if invalid:
                h.flash(_("Invalid email addresses: %(email_list)s") % \
                        dict(email_list=', '.join(invalid)))
            if already:
                h.flash(_("These addresses are already registered in Ututi: %(email_list)s") % \
                        dict(email_list=', '.join(already)))
            if invites:
                h.flash(_("Invitations sent to %(email_list)s") % \
                        dict(email_list=', '.join(invite.email for invite in invites)))

        if request.referrer:
            redirect(request.referrer)
        else:
            redirect(url(controller='profile', action='home'))

    @js_validate(schema=FriendsInvitationJSForm())
    @jsonify
    def invite_friends_email_js(self):
        if hasattr(self, 'form_result'):
            emails = self.form_result['recipients']
            message = self.form_result['message']
            invites, invalid, already = \
                make_email_invitations(emails, c.user, c.user.location)
            meta.Session.commit()
            for invitee in invites:
                send_registration_invitation(invitee, c.user, message)

        return {'success': True}

    def invite_friends_fb(self):
        # handle facebook callback
        ids = request.params.get('ids[]')
        if ids:
            ids = map(int, ids.split(','))
            invited = make_facebook_invitations(ids, c.user, c.user.location)
            meta.Session.commit()
            if invited:
                h.flash(ungettext('Invited %(num)d friend.',
                                  'Invited %(num)d friends.',
                                  len(invited)) % dict(num=len(invited)))

            redirect(url(controller='profile', action='home'))

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
                        .filter(User.location == c.user.location).all()
                c.exclude_ids = ','.join(str(u.facebook_id) for u in friend_users)
            except facebook.GraphAPIError:
                c.has_facebook = False

        return render('profile/invite_friends_fb.mako')
