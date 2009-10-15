from datetime import date
import logging

from pkg_resources import resource_stream

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import desc, or_, asc, func
from formencode import Schema, validators, htmlfill
from webhelpers import paginate

from pylons import request, c, url
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect_to
from pylons.decorators import validate
from pylons.i18n import _

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.emails import email_confirmation_request
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query, search_query_count
from ututi.lib.image import serve_image

from ututi.model.events import Event
from ututi.model import Subject
from ututi.model import LocationTag
from ututi.model import meta, Email, Group, SearchItem
from ututi.controllers.group import _filter_watched_subjects, FileUploadTypeValidator
from ututi.controllers.search import SearchSubmit, SearchBaseController

log = logging.getLogger(__name__)


class ProfileForm(Schema):
    """A schema for validating user profile forms."""
    allow_extra_fields = True
    fullname = validators.String(not_empty=True)
    site_url = validators.URL()


class LogoUpload(Schema):
    """A schema for validating logo uploads."""
    logo = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))


class ProfileController(SearchBaseController):
    """A controller for the user's personal information and actions."""
    def __before__(self):
        c.breadcrumbs = [{'title': c.user.fullname, 'link': url(controller='profile', action='index')}]

    @ActionProtector("user")
    @validate(schema=SearchSubmit, form='index', post_only = False, on_get = True)
    def search(self):
        self._search()
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
        c.events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in c.user.watched_subjects]),
                        Event.object_id.in_([m.group.id for m in c.user.memberships])))\
            .filter(Event.author_id != c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()

        if not c.events:
            redirect_to(controller='profile', action='welcome')

        return render('/profile/home.mako')

    def _edit_form(self):
        return render('profile/edit.mako')

    @ActionProtector("user")
    def edit(self):
        defaults = {
            'fullname': c.user.fullname,
            'site_url': c.user.site_url,
            'description': c.user.description,
            }

        return htmlfill.render(self._edit_form(), defaults=defaults)

    @validate(LogoUpload)
    @ActionProtector("user")
    def logo_upload(self):
        if self.form_result['logo'] is not None:
            logo = self.form_result['logo']
            c.user.logo = logo.file.read()
            meta.Session.commit()
            return ''

    @validate(ProfileForm, form='_edit_form')
    @ActionProtector("user")
    def update(self):
        fields = ('fullname', 'logo_upload', 'logo_delete', 'site_url', 'description')
        values = {}

        for field in fields:
            values[field] = self.form_result.get(field, None)

        c.user.fullname = values['fullname']
        c.user.site_url = values['site_url']
        c.user.description = values['description']

        if values['logo_delete'] == 'delete' and c.user.logo is not None:
            c.user.logo = None

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            c.user.logo = logo.file.read()

        meta.Session.commit()
        h.flash(_('Your profile was updated.'))
        redirect_to(controller='profile', action='index')

    def confirm_emails(self):
        if c.user is not None:
            emails = request.POST.getall('email')
            for email in emails:
                email_confirmation_request(c.user, email)
            redirect_to(controller='profile', action='index')
        else:
            redirect_to(controller='home', action='index')

    def confirm_user_email(self, key):
        try:
            email = meta.Session.query(Email).filter_by(confirmation_key=key).one()
            email.confirmed = True
            email.confirmation_key = ''
            meta.Session.commit()
            h.flash(_("Your email %s was confirmed. Thank You." % email.email))
        except NoResultFound:
            h.flash(_("Could not confirm email - invalid confirmation key."))

        redirect_to(url(controller='profile', action='index'))

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @ActionProtector("user")
    def subjects(self):
        c.search_target = url(controller='profile', action='subjects')

        #retrieve search parameters
        c.text = self.form_result.get('text', '')

        tags = []

        if 'tagsitem' in self.form_result:
            tags = self.form_result.get('tagsitem', None)
        elif 'tags' in self.form_result:
            tags = self.form_result.get('tags', [])
            if isinstance(tags, str):
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

        return render('profile/subjects.mako')

    def _getSubject(self):
        location_id = request.GET['subject_location_id']
        location = meta.Session.query(LocationTag).filter_by(id=location_id).one()
        subject_id = request.GET['subject_id']
        return Subject.get(location, subject_id)

    def _watch_subject(self):
        c.user.watchSubject(self._getSubject())
        meta.Session.commit()

    def _unwatch_subject(self):
        c.user.ignoreSubject(self._getSubject())
        meta.Session.commit()

    @ActionProtector("user")
    def watch_subject(self):
        self._watch_subject()
        redirect_to(request.referrer)

    @ActionProtector("user")
    def js_watch_subject(self):
        self._watch_subject()
        return render_mako_def('profile/subjects.mako',
                               'subject_flash_message',
                               subject=self._getSubject()) +\
            render_mako_def('profile/subjects.mako',
                            'watched_subject',
                            subject=self._getSubject())

    @ActionProtector("user")
    def unwatch_subject(self):
        self._unwatch_subject()
        redirect_to(request.referrer)

    @ActionProtector("user")
    def js_unwatch_subject(self):
        self._unwatch_subject()
        return "OK"

    @ActionProtector("user")
    def welcome(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return  render('profile/welcome.mako')

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
            if isinstance(tags, str) or isinstance(tags, unicode):
                tags = tags.split(', ')

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

        c.results = paginate.Page(
            results,
            page=int(request.params.get('page', 1)),
            item_count = search_query_count(results),
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
