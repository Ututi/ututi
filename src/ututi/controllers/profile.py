from datetime import date
import logging

from sqlalchemy.sql.expression import desc
from formencode import Schema, validators
from routes import url_for
from webhelpers import paginate

from pylons import request, c, url
from pylons.templating import render_mako_def
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from ututi.lib.base import BaseController, render
from ututi.lib.emails import email_confirmation_request
from ututi.lib.security import ActionProtector
from ututi.lib.search import search_query

from ututi.model.events import Event
from ututi.model import Subject
from ututi.model import LocationTag
from ututi.model import meta, Email, File, Group, SearchItem
from ututi.controllers.group import _filter_watched_subjects
from ututi.controllers.search import SearchSubmit

log = logging.getLogger(__name__)


class ProfileForm(Schema):
    """A schema for validating user profile forms."""
    allow_extra_fields = True
    fullname = validators.String(not_empty=True)


class ProfileController(BaseController):
    """A controller for the user's personal information and actions."""

    @ActionProtector("user")
    def index(self):
        c.fullname = c.user.fullname
        c.emails = [email.email for email in
                    meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=False).all()]
        c.emails_confirmed = [email.email for email in
                              meta.Session.query(Email).filter_by(id=c.user.id).filter_by(confirmed=True).all()]
        return render('profile/profile.mako')

    @ActionProtector("user")
    def home(self):
        c.events = meta.Session.query(Event)\
            .filter(Event.object_id.in_([s.id for s in c.user.watched_subjects]))\
            .filter(Event.author_id != c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()

        if not c.events:
            redirect_to(controller='profile', action='welcome')

        return render('/profile/home.mako')

    @ActionProtector("user")
    def edit(self):
        c.breadcrumbs = [
            {'title': c.user.fullname,
             'link': url_for(controller='profile', action='index', id=c.user.id)},
            {'title': _('Edit'),
             'link': url_for(controller='profile', action='edit', id=c.user.id)}
            ]

        return render('profile/edit.mako')

    @validate(ProfileForm, form='edit')
    @ActionProtector("user")
    def update(self):
        fields = ('fullname', 'logo_upload', 'logo_delete')
        values = {}

        for field in fields:
            values[field] = request.POST.get(field, None)

        c.user.fullname = values['fullname']

        if values['logo_delete'] == 'delete' and c.user.logo is not None:
            meta.Session.delete(c.user.logo)
            c.user.logo = None

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            f = File(logo.filename, 'Avatar for %s' % c.user.fullname, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)
            if c.user.logo is not None:
                meta.Session.delete(c.user.logo)
            c.user.logo = f

        meta.Session.commit()
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
        email = meta.Session.query(Email).filter_by(confirmation_key=key).first()
        email.confirmed = True
        email.confirmation_key = ''
        meta.Session.commit()
        redirect_to(controller='profile', action='index')

    @validate(schema=SearchSubmit, form='subjects', post_only = False, on_get = True)
    @ActionProtector("user")
    def subjects(self):
        c.search_target = url(controller='profile', action='subjects')

        #retrieve search parameters
        c.text = self.form_result.get('text', '')

        if 'tagsitem' in self.form_result or 'tags' in self.form_result:
            c.tags = self.form_result.get('tagsitem', None)
            if c.tags is None:
                c.tags = self.form_result.get('tags', None).split(', ')
        c.tags = ', '.join(filter(bool, c.tags))

        sids = [s.id for s in c.user.watched_subjects]

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        search_params['obj_type'] = 'subject'

        if search_params != {}:
            c.results = paginate.Page(
                search_query(extra=_filter_watched_subjects(sids), **search_params),
                page=int(request.params.get('page', 1)),
                items_per_page = 10,
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
        c.tags = self.form_result.get('tagsitem', None)
        if c.tags is None:
            c.tags = self.form_result.get('tags', '').split(', ')
        c.tags.extend(self.form_result.get('location', []))
        c.tags = filter(bool, c.tags)

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
                search_params['year'] = c.year
                results = results.join((Group, SearchItem.content_item_id == Group.id))\
                    .filter(Group.year == date(int(c.year), 1, 1))

        c.year = c.year and int(c.year) or date.today().year
        c.years = range(date.today().year - 10, date.today().year + 5)
        c.tags = ', '.join(c.tags)

        c.results = paginate.Page(
            results,
            page=int(request.params.get('page', 1)),
            items_per_page = 10,
            **search_params)

        return render('profile/findgroup.mako')
