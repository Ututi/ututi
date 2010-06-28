from datetime import date
import logging

from pkg_resources import resource_stream

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import desc, or_, asc, func
from formencode import Schema, validators, htmlfill, All
from formencode.compound import Pipe
from formencode.foreach import ForEach
from formencode.api import Invalid
from formencode.variabledecode import NestedVariables
from webhelpers import paginate

from pylons import request, tmpl_context as c, url
from pylons.templating import render_mako_def
from pylons.controllers.util import abort, redirect

from pylons.i18n import _

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.emails import email_confirmation_request
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query, search_query_count
from ututi.lib.image import serve_image
from ututi.lib.validators import UserPasswordValidator, UniqueEmail, LocationTagsValidator, manual_validate
from ututi.lib.forms import validate
from ututi.lib import gg

from ututi.model.events import Event
from ututi.model import get_supporters
from ututi.model import Subject, LocationTag, BlogEntry, PrivateMessage
from ututi.model import meta, Email, Group, SearchItem
from ututi.controllers.group import _filter_watched_subjects, FileUploadTypeValidator
from ututi.controllers.search import SearchSubmit, SearchBaseController
from ututi.controllers.home import sign_in_user
from ututi.controllers.home import UniversityListMixin

log = logging.getLogger(__name__)


class LocationForm(Schema):
    pre_validators = [NestedVariables()]
    allow_extra_fields = True
    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())


class ProfileForm(LocationForm):
    """A schema for validating user profile forms."""
    fullname = validators.String(not_empty=True)
    site_url = validators.URL()


class PasswordChangeForm(Schema):
    allow_extra_fields = False

    password = UserPasswordValidator(not_empty=True)

    msg = {'empty': _(u"Please enter your password to register."),
           'tooShort': _(u"The password must be at least 5 symbols long.")}

    new_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)

    repeat_password = validators.String(
        min=5, not_empty=True, strip=True, messages=msg)

    msg = {'invalid': _(u"Passwords do not match."),
           'invalidNoMatch': _(u"Passwords do not match."),
           'empty': _(u"Please enter your password to register.")}
    chained_validators = [validators.FieldsMatch('new_password',
                                                 'repeat_password',
                                                 messages=msg)]


class GaduGaduConfirmationNumber(validators.FormValidator):

    messages = {
        'invalid': _(u"This is not the confirmation code we sent you."),
    }

    def validate_python(self, form_dict, state):
        if not form_dict['gadugadu_confirmation_key']:
            return
        if not form_dict['confirm_gadugadu'] and not form_dict['update_contacts']:
            return
        if (form_dict['gadugadu_confirmation_key'] and
            c.user.gadugadu_uin == form_dict['gadugadu_uin'] and
            c.user.gadugadu_confirmation_key.strip() == form_dict['gadugadu_confirmation_key']):
            return

        raise Invalid(self.message('invalid', state),
                      form_dict, state,
                      error_dict={'gadugadu_confirmation_key': Invalid(self.message('invalid', state), form_dict, state)})


class ContactForm(Schema):

    allow_extra_fields = False

    msg = {'non_unique': _(u"This email is already in use.")}
    email = All(validators.Email(not_empty=True, strip=True),
                UniqueEmail(messages=msg, strip=True))


    gadugadu_uin = validators.Int()
    gadugadu_confirmation_key = validators.String()
    gadugadu_get_news = validators.StringBool(if_missing=False)

    confirm_email = validators.Bool()

    confirm_gadugadu = validators.Bool()

    resend_gadugadu_code = validators.Bool()

    update_contacts = validators.Bool()

    chained_validators = [GaduGaduConfirmationNumber()]


class LogoUpload(Schema):
    """A schema for validating logo uploads."""
    logo = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))


class HideElementForm(Schema):
    """Ajax submit validator to hide welcome screen widgets."""
    allow_extra_fields = False
    type = validators.OneOf(['hide_suggest_create_group', 'hide_suggest_watch_subject'])


class ProfileController(SearchBaseController, UniversityListMixin):
    """A controller for the user's personal information and actions."""

    def __before__(self):
        c.ututi_supporters = get_supporters()
        if c.user is not None:
            c.breadcrumbs = [{'title': c.user.fullname, 'link': url(controller='profile', action='home')}]
            c.blog_entries = meta.Session.query(BlogEntry).order_by(BlogEntry.created.desc()).limit(10).all()

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        bcs = {
            'home':
            {'title': _("What's New?"),
             'link': url(controller='profile', action='home')},
            'subjects':
            {'title': _("Subjects"),
             'link': url(controller='profile', action='subjects')}
            }
        if selected in bcs.keys():
            return bcs[selected]

    @ActionProtector("user")
    def browse(self):
        c.breadcrumbs = [{'title': _('Search'), 'link': url(controller='profile', action='browse')}]
        self._get_unis()

        c.obj_type = '*'
        if request.params.has_key('js'):
            return render_mako_def('/anonymous_index/lt.mako', 'universities',
                                   unis=c.unis, ajax_url=url(controller='profile', action='browse'))

        return render('/profile/browse.mako')

    @ActionProtector("user")
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def search(self):
        c.breadcrumbs = [{'title': _('Search'), 'link': url(controller='profile', action='browse')}]
        self._search()
        self._search_locations(self.form_result.get('text', ''))
        return render('/profile/search.mako')

    @ActionProtector("user")
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def search_js(self):
        self._search()
        return render_mako_def('/search/index.mako','search_results', results=c.results, controller='profile', action='search')

    @ActionProtector("user")
    def index(self):
        c.events = meta.Session.query(Event)\
            .filter(Event.author_id == c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()

        c.fullname = c.user.fullname
        c.emails = [email.email for email in
                    meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=False).all()]
        c.emails_confirmed = [email.email for email in
                              meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=True).all()]
        return render('profile/profile.mako')

    @ActionProtector("user")
    def home(self):
        c.breadcrumbs.append(self._actions('home'))

        c.events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in c.user.all_watched_subjects]),
                        Event.object_id.in_([m.group.id for m in c.user.memberships])))\
            .filter(Event.author_id != c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()
        c.action = 'home'

        return render('/profile/home.mako')

    @ActionProtector("user")
    def feed(self):
        c.breadcrumbs.append(self._actions('home'))
        c.events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in c.user.all_watched_subjects]),
                        Event.object_id.in_([m.group.id for m in c.user.memberships])))\
            .filter(Event.author_id != c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()

        c.action = 'feed'
        return render('/profile/feed.mako')

    def _edit_form(self, defaults=None):
        return render('profile/edit.mako')

    def _edit_form_defaults(self):
        defaults = {
            'email': c.user.emails[0].email,
            'gadugadu_uin': c.user.gadugadu_uin,
            'gadugadu_get_news': c.user.gadugadu_get_news,
            'fullname': c.user.fullname,
            'site_url': c.user.site_url,
            'description': c.user.description,
            }
        if c.user.location is not None:
            location = dict([('location-%d' % n, tag)
                             for n, tag in enumerate(c.user.location.hierarchy())])
        else:
            location = []
        defaults.update(location)

        return defaults

    @ActionProtector("user")
    def edit(self):
        return htmlfill.render(self._edit_form(),
                               defaults=self._edit_form_defaults())

    @validate(PasswordChangeForm, form='_edit_form',
              ignore_request=True, defaults=_edit_form_defaults)
    @ActionProtector("user")
    def password(self):
        if hasattr(self, 'form_result'):
            c.user.update_password(self.form_result['new_password'].encode('utf-8'))
            meta.Session.commit()
            h.flash(_('Your password has been changed!'))
            redirect(url(controller='profile', action='home'))
        else:
            redirect(url(controller='profile', action='edit'))

    @validate(LogoUpload)
    @ActionProtector("user")
    def logo_upload(self):
        if self.form_result['logo'] is not None:
            logo = self.form_result['logo']
            c.user.logo = logo.file.read()
            meta.Session.commit()
            return ''

    @validate(ProfileForm, form='_edit_form', defaults=_edit_form_defaults)
    @ActionProtector("user")
    def update(self):
        fields = ('fullname', 'logo_upload', 'logo_delete', 'site_url', 'description', 'location')
        values = {}

        for field in fields:
            values[field] = self.form_result.get(field, None)

        c.user.fullname = values['fullname']
        c.user.site_url = values['site_url']
        c.user.description = values['description']
        tag = values.get('location', None)
        c.user.location = tag


        if values['logo_delete'] == 'delete' and c.user.logo is not None:
            c.user.logo = None

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            c.user.logo = logo.file.read()

        meta.Session.commit()
        h.flash(_('Your profile was updated.'))
        redirect(url(controller='profile', action='home'))

    def confirm_emails(self):
        if c.user is not None:
            emails = request.POST.getall('email')
            for email in emails:
                email_confirmation_request(c.user, email)
            h.flash(_('Confirmation message sent. Please check your email.'))
            dest = request.POST.get('came_from', None)
            if dest is not None:
                redirect(dest.encode('utf-8'))
            else:
                redirect(url(controller='profile', action='edit'))
        else:
            redirect(url(controller='home', action='home'))

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
    def subjects(self):
        c.breadcrumbs.append(self._actions('subjects'))
        c.subjects = c.user.watched_subjects
        c.groups = c.user.groups
        return render('profile/subjects.mako')

    @validate(schema=SearchSubmit, form='watch_subjects', post_only=False, on_get=True)
    @ActionProtector("user")
    def watch_subjects(self):

        c.breadcrumbs.append(self._actions('subjects'))

        c.search_target = url(controller='profile', action='watch_subjects')

        #retrieve search parameters
        c.text = self.form_result.get('text', '')

        tags = []

        if 'tagsitem' in self.form_result:
            tags = self.form_result.get('tagsitem', None)
        elif 'tags' in self.form_result:
            tags = self.form_result.get('tags', [])
            if isinstance(tags, basestring):
                tags = tags.split(', ')

        c.tags = ', '.join(filter(bool, tags))

        sids = [s.id for s in c.user.watched_subjects]

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        search_params['obj_type'] = 'subject'

        query = search_query(extra=_filter_watched_subjects(sids), **search_params)
        if search_params != {}:
            c.results = paginate.Page(
                query,
                page=int(request.params.get('page', 1)),
                items_per_page = 10,
                item_count = search_query_count(query),
                **search_params)

        c.watched_subjects = c.user.watched_subjects

        return render('profile/watch_subjects.mako')

    def _getSubject(self):
        subject_id = request.GET['subject_id']
        return Subject.get_by_id(int(subject_id))

    def _watch_subject(self):
        c.user.watchSubject(self._getSubject())
        meta.Session.commit()

    def _unwatch_subject(self):
        c.user.unwatchSubject(self._getSubject())
        meta.Session.commit()

    @ActionProtector("user")
    def watch_subject(self):
        self._watch_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_watch_subject(self):
        self._watch_subject()
        return render_mako_def('profile/watch_subjects.mako',
                               'subject_flash_message',
                               subject=self._getSubject()) +\
            render_mako_def('profile/watch_subjects.mako',
                            'watched_subject',
                            subject=self._getSubject(),
                            new = True)

    @ActionProtector("user")
    def unwatch_subject(self):
        self._unwatch_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_unwatch_subject(self):
        self._unwatch_subject()
        return "OK"

    def _ignore_subject(self):
        c.user.ignoreSubject(self._getSubject())
        meta.Session.commit()

    def _unignore_subject(self):
        c.user.unignoreSubject(self._getSubject())
        meta.Session.commit()

    @ActionProtector("user")
    def ignore_subject(self):
        self._ignore_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_ignore_subject(self):
        self._ignore_subject()
        return "OK"

    @ActionProtector("user")
    def unignore_subject(self):
        self._unignore_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_unignore_subject(self):
        self._unignore_subject()
        return "OK"

    @ActionProtector("user")
    def register_welcome(self):
        return render('profile/home.mako')

    @validate(schema=SearchSubmit, form='test', post_only = False, on_get = True)
    @ActionProtector("user")
    def findgroup(self):
        """Find the requested group, filtering by location id and year."""
        #collect default search parameters
        c.text = self.form_result.get('text', '')

        tags = []

        if 'tagsitem' in self.form_result:
            tags = self.form_result.get('tagsitem', None)
        elif 'tags' in self.form_result:
            tags = self.form_result.get('tags', [])
            if isinstance(tags, basestring):
                tags = tags.split(', ')
        elif c.user.location is not None:
            tags = c.user.location.hierarchy()

        c.tags = tags

        c.tags.extend(self.form_result.get('location', []))
        c.tags = filter(bool, c.tags)

        #keep location information for group creation view
        c.location = LocationTag.get_by_title(filter(bool, self.form_result.get('location', [])))
        if c.location is not None:
            c.location = '/'.join(c.location.path)

        #extra search parameters
        c.year = self.form_result.get('year', None)

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        else:
            search_params['tags'] = []

        search_params['obj_type'] = 'group'

        if search_params != {}:
            results = search_query(**search_params)

            if c.year is not None:
                try:
                    c.year = int(c.year)
                    search_params['year'] = c.year
                    results = results.join((Group, SearchItem.content_item_id == Group.id))\
                        .order_by(asc(func.abs(Group.year - date(int(c.year), 1, 1))))

                except:
                    pass

        c.year = c.year and int(c.year) or date.today().year
        c.years = range(date.today().year - 10, date.today().year + 5)
        c.tags = ', '.join(c.tags)

        # XXX OMG WTF PYLONS URL_FOR!
        # url_for can't encode unicode parameters itself
        # as it is used by paginate.Page we must do that for it
        # weird, because url manages to accomplish this task pretty easily
        search_params['tags'] = [tag.encode('utf-8')
                                 for tag in search_params['tags']]
        c.results = paginate.Page(
            results,
            page=int(request.params.get('page', 1)),
            item_count = results.count() or 0,
            items_per_page = 10,
            **search_params)

        return render('profile/findgroup.mako')

    @ActionProtector("user")
    def logo(self, width=None, height=None):
        if c.user.logo is not None:
            return serve_image(c.user.logo, width, height)
        else:
            stream = resource_stream("ututi", "public/images/user_ico.png").read()
            return serve_image(stream, width, height)

    @ActionProtector("user")
    def set_receive_email_each(self):
        if request.params.get('each') in ('day', 'hour', 'never'):
            c.user.receive_email_each = request.params.get('each')
            meta.Session.commit()
        if request.params.get('ajax'):
            return 'OK'
        redirect(url(controller='profile', action='subjects'))

    @validate(ContactForm, form='_edit_form', defaults=_edit_form_defaults)
    @ActionProtector("user")
    def update_contacts(self):
        if hasattr(self, 'form_result'):
            if self.form_result['confirm_email']:
                h.flash(_('Confirmation message sent. Please check your email.'))
                email_confirmation_request(c.user, c.user.emails[0].email)
                redirect(url(controller='profile', action='edit'))

            # handle email
            email = self.form_result['email']
            if email != c.user.emails[0].email:
                c.user.emails[0].email = email
                c.user.emails[0].confirmed = False
                email_confirmation_request(c.user, email)
                meta.Session.commit()
                sign_in_user(email)

            gadugadu_uin = self.form_result['gadugadu_uin']
            gadugadu_confirmation_key = self.form_result['gadugadu_confirmation_key']

            if self.form_result['resend_gadugadu_code']:
                gg.confirmation_request(c.user)
                meta.Session.commit()
            elif gadugadu_uin != c.user.gadugadu_uin:
                c.user.gadugadu_uin = gadugadu_uin
                c.user.gadugadu_confirmed = False
                c.user.gadugadu_get_news = False
                if gadugadu_uin:
                    gg.confirmation_request(c.user)
                meta.Session.commit()
            elif gadugadu_confirmation_key:
                c.user.gadugadu_confirmed = True
                meta.Session.commit()
            else:
                c.user.gadugadu_get_news = self.form_result['gadugadu_get_news']
                meta.Session.commit()

            redirect(url(controller='profile', action='edit'))
        else:
            redirect(url(controller='profile', action='edit'))

    @ActionProtector("user")
    def thank_you(self):
        return render('/profile/thank_you.mako')

    @ActionProtector("user")
    def no_thank_you(self):
        return render('/profile/no_thank_you.mako')

    @ActionProtector("user")
    def support(self):
        return render('/profile/support.mako')

    @ActionProtector("user")
    @validate(schema=LocationForm, form='home')
    def update_location(self):
        c.user.location = self.form_result.get('location', None)
        meta.Session.commit()
        h.flash(_('Your university information has been updated.'))
        redirect(url(controller='profile', action='home'))

    @ActionProtector("user")
    def js_update_location(self):
        try:
            fields = manual_validate(LocationForm)
            c.user.location = fields.get('location', None)
            meta.Session.commit()
            return render_mako_def('/profile/home.mako','location_updated')
        except Invalid, e:
            abort(400)

    @ActionProtector("user")
    @validate(schema=LocationForm, form='home')
    def goto_location(self):
        if hasattr(self, 'form_result'):
            location = self.form_result.get('location', None)
            if location is not None:
                redirect(location.url())
        redirect(url(controller='profile', action='home'))

    @ActionProtector("user")
    @validate(schema=HideElementForm)
    def js_hide_element(self):
        if self.form_result['type'] == 'hide_suggest_create_group':
            c.user.hide_suggest_create_group = True
            meta.Session.commit()
        elif self.form_result['type'] == 'hide_suggest_watch_subject':
            c.user.hide_suggest_watch_subject = True
            meta.Session.commit()

    @ActionProtector("user")
    def js_all_subjects(self):
        subjects = c.user.all_watched_subjects
        subjects = sorted(subjects, key=lambda subject: subject.title)

        return render_mako_def('/profile/home.mako', 'subjects_block', subjects=subjects)

    @ActionProtector("user")
    def js_my_subjects(self):
        subjects = c.user.watched_subjects
        subjects = sorted(subjects, key=lambda subject: subject.title)

        return render_mako_def('/profile/home.mako','subjects_block', subjects=subjects)
