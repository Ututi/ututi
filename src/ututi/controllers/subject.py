import logging
from random import Random
import string

from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, htmlfill

from webhelpers import paginate

from pylons import tmpl_context as c, request, url, session
from pylons.controllers.util import redirect, abort
from pylons.i18n import _
from pylons.templating import render_mako_def

from ututi.model import SearchItem
from ututi.model import meta, LocationTag, Subject, File, SimpleTag
from ututi.model.events import Event
from ututi.lib.security import ActionProtector, deny
from ututi.lib.search import search, search_query, search_query_count
from ututi.lib.fileview import FileViewMixin
from ututi.lib.base import BaseController, render, u_cache
from ututi.lib.validators import LocationTagsValidator, TagsValidator, validate
from ututi.lib.wall import WallMixin
import ututi.lib.helpers as h

log = logging.getLogger(__name__)


def set_login_url_to_referrer(method):
    def _set_login_url(self, subject):
        c.login_form_url = request.referrer
        return method(self, subject)
    return _set_login_url


def subject_menu_items():
    return [
        {'title': _("Subject information"),
         'name': 'info',
         'link': c.subject.url(action='info')},
        {'title': _("News feed"),
         'name': 'feed',
         'link': c.subject.url(action='feed')},
        {'title': _("Files"),
         'name': 'files',
         'link': c.subject.url(action='files')},
        {'title': _("Notes"),
         'name': 'pages',
         'link': c.subject.url(action='pages')}]


@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def find_similar_subjects(subject, n=5):
    """Find 5 similar subjects to the one given."""
    def filter_out(query):
        return query.filter(SearchItem.content_item_id != subject.id)
    results = search(text=subject.title, obj_type='subject', disjunctive=False, limit=n, extra=filter_out)
    if not results:
        results = search(text=subject.title, obj_type='subject', tags=subject.location.hierarchy(), disjunctive=True, limit=5, extra=filter_out, rank_cutoff=0.1)
    return [item.object.info_dict() for item in results]


def subject_action(method):
    def _subject_action(self, id, tags):
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)

        if subject is None:
            abort(404)

        c.security_context = subject
        c.object_location = subject.location
        c.subject = subject
        c.similar_subjects = find_similar_subjects(subject)
        c.tabs = subject_menu_items()
        c.breadcrumbs = [{'link': subject.url(), 'title': subject.title}]
        return method(self, subject)
    return _subject_action


class SubjectForm(Schema):
    """A schema for validating new subject forms."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
                    LocationTagsValidator())

    title = validators.UnicodeString(not_empty=True, strip=True)
    lecturer = validators.UnicodeString(strip=True)
    chained_validators = [
        TagsValidator()
        ]


class SubjectLightForm(Schema):
    allow_extra_fields = True
    pre_validators = [NestedVariables()]

    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
                    LocationTagsValidator())

    msg = {'empty': _("Please enter subject title")}
    title = validators.UnicodeString(not_empty=True, strip=True, messages=msg)


class SearchSubjectForm(Schema):
    """An identical schema for searching subjects from subject create form."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
                    LocationTagsValidator())

    title = validators.UnicodeString(strip=True)
    lecturer = validators.UnicodeString(strip=True)
    chained_validators = [
        TagsValidator()
        ]


class NewSubjectForm(SubjectForm):
    pass


class SubjectAddMixin(object):

    def _create_subject(self):
        title = self.form_result['title']
        id = ''.join(Random().sample(string.ascii_lowercase, 8)) # use random id first
        lecturer = self.form_result['lecturer']
        location = self.form_result['location']
        description = self.form_result['description']

        if lecturer == '':
            lecturer = None

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', [])]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',')]

        stags = []
        for tag in tags:
            stags.append(SimpleTag.get(tag))


        subj = Subject(id, title, location, lecturer, description, stags)

        meta.Session.add(subj)
        meta.Session.flush()

        newid = subj.generate_new_id()
        if newid is not None:
            subj.subject_id = newid

        return subj


class SubjectWallMixin(WallMixin):

    def _wall_events_query(self):
        """WallMixin implementation."""

        query = meta.Session.query(Event)\
             .filter(Event.object_id == c.subject.id)

        return query


class SubjectController(BaseController, FileViewMixin, SubjectAddMixin, SubjectWallMixin):
    """A controller for subjects."""

    @subject_action
    def home(self, subject):
        blank_subject = not subject.pages and not subject.n_files(include_deleted=False)
        if not (subject.description or blank_subject):
            redirect(subject.url(action='feed'))
        c.current_tab = 'info'
        return render('subject/info.mako')

    @subject_action
    def info(self, subject):
        c.current_tab = 'info'
        return render('subject/info.mako')

    @subject_action
    def files(self, subject):
        c.current_tab = 'files'
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file
        return render('subject/home_files.mako')

    @subject_action
    def pages(self, subject):
        c.current_tab = 'pages'
        return render('subject/home_pages.mako')

    @subject_action
    def feed(self, subject):
        c.current_tab = 'feed'
        self._set_wall_variables()
        return render('subject/feed.mako')

    def _add_form(self):
        return render('subject/add.mako')

    @ActionProtector("user")
    def add(self):
        defaults = dict([('location-%d' % n, tag)
                         for n, tag in enumerate(c.user.location.hierarchy())])
        c.hide_location = True
        return htmlfill.render(self._add_form(), defaults=defaults)

    @ActionProtector("user")
    @validate(schema=SubjectLightForm, form='_add_form')
    def lookup(self):
        # save posted variables for future
        title = self.form_result['title']
        location = self.form_result['location']
        session['subject_title'] = title
        session['subject_location_id'] = location.id
        session.save()

        # lookup for subjects similar to the one
        # that is about to be created
        search_params = {}
        search_params['obj_type'] = 'subject'
        search_params['text'] = title
        search_params['tags'] = ', '.join(location.title_path)

        query = search_query(**search_params)
        c.similar_subjects = paginate.Page(
            query,
            items_per_page = 30,
            item_count = search_query_count(query),
            **search_params)

        if c.similar_subjects:
            return render('subject/add_lookup.mako')
        else:
            # no similar subjects found
            return redirect(url(controller='subject', action='add_description'))

    def _add_full_form(self):
        return render('subject/add_description.mako')

    @ActionProtector("user")
    def add_description(self):
        if 'subject_title' not in session or \
           'subject_location_id' not in session:
            redirect(url(controller='subject', action='add'))

        defaults = dict(title=session['subject_title'])
        if c.user.is_teacher:
            defaults['lecturer'] = c.user.fullname
        location = LocationTag.get(session['subject_location_id'])
        tags = dict([('location-%d' % n, tag)
                    for n, tag in enumerate(location.hierarchy())])
        defaults.update(tags)

        return htmlfill.render(self._add_full_form(),
                               defaults=defaults)

    @validate(schema=NewSubjectForm, form='_add_full_form')
    @ActionProtector("user")
    def create(self):
        if not hasattr(self, 'form_result'):
            redirect(url(controller='subject', action='add'))

        subj = self._create_subject()
        meta.Session.commit()

        if c.user.is_teacher and c.user.teacher_verified:
            c.user.teach_subject(subj)
            meta.Session.commit()

        if self.form_result.has_key('watch_subject'):
            c.user.watchSubject(subj)
            meta.Session.commit()
            h.flash(_('You are now watching the subject %s') % subj.title)

        redirect(url(controller='subject',
                    action='home',
                    id=subj.subject_id,
                    tags=subj.location_path))

    def _edit_form(self):
        return render('subject/edit.mako')

    @subject_action
    @ActionProtector("user")
    def edit(self, subject):
        defaults = {
            'id': subject.subject_id,
            'old_location': '/'.join(subject.location.path),
            'title': subject.title,
            'lecturer': subject.lecturer,
            'tags': ', '.join([tag.title for tag in subject.tags]),
            'description': subject.description,
            }
        c.hide_location = True

        if subject.location is not None:
            location = dict([('location-%d' % n, tag)
                             for n, tag in enumerate(subject.location.hierarchy())])
        else:
            location = []

        defaults.update(location)
        return htmlfill.render(self._edit_form(), defaults=defaults)

    @subject_action
    @ActionProtector("user")
    def watch(self, subject):
        if not c.user.watches(subject):
            c.user.watchSubject(subject)
            h.flash(_("The subject has been added to your watched subjects list."))
        else:
            c.user.unwatchSubject(subject)
            h.flash(_("The subject has been removed from your watched subjects list."))

        meta.Session.commit()

        redirect(url(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path))

    @subject_action
    @ActionProtector("verified_teacher")
    def teach(self, subject):
        if not c.user.teaches(subject):
            c.user.teach_subject(subject)
            h.flash(render_mako_def('subject/flash_messages.mako',
                                    'teach_subject',
                                    subject=subject))
        else:
            h.flash(_("The course is already in your taught courses list."))

        meta.Session.commit()

        redirect(url(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path))

    @subject_action
    @ActionProtector("teacher")
    def unteach(self, subject):
        if c.user.teaches(subject):
            c.user.unteach_subject(subject)
            h.flash(render_mako_def('subject/flash_messages.mako',
                                    'unteach_subject',
                                    subject=subject))
        else:
            h.flash(_("The course was not in your taught courses list."))

        meta.Session.commit()

        redirect(url(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path))

    @subject_action
    @validate(schema=SubjectForm, form='_edit_form')
    @ActionProtector("user")
    def update(self, subject):
        if not hasattr(self, 'form_result'):
            redirect(url(controller='subject', action='add'))

        #check if we need to regenerate the id
        clash = Subject.get(self.form_result.get('location', None), subject.subject_id)
        if clash is not None and clash is not subject:
            subject.subject_id = subject.generate_new_id()


        subject.title = self.form_result['title']
        subject.lecturer = self.form_result['lecturer']
        subject.location = self.form_result['location']
        subject.description = self.form_result.get('description', None)

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', []) if len(tag.strip().lower()) < 250 and tag.strip() != '']
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',') if len(tag.strip()) < 250 and tag.strip() != '']

        subject.tags = []
        for tag in tags:
            subject.tags.append(SimpleTag.get(tag))


        meta.Session.commit()

        redirect(url(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path))

    @subject_action
    @set_login_url_to_referrer
    @ActionProtector("user")
    def upload_file(self, subject):
        return self._upload_file(subject)

    @subject_action
    @set_login_url_to_referrer
    @ActionProtector("user")
    def upload_file_short(self, subject):
        return self._upload_file_short(subject)

    @subject_action
    @ActionProtector("user")
    def create_folder(self, subject):
        self._create_folder(subject)
        redirect(subject.url())

    @subject_action
    @ActionProtector("user")
    def delete_folder(self, subject):
        folder_name = request.params['folder']
        if not subject.getFolder(folder_name).can_write(c.user):
            deny(_('You have no right to delete this folder.'), 403)
        else:
            self._delete_folder(subject)
            redirect(request.referrer)

    @subject_action
    @ActionProtector("user")
    def js_create_folder(self, subject):
        return self._create_folder(subject)

    @subject_action
    @ActionProtector("user")
    def js_delete_folder(self, subject):
        folder_name = request.params['folder']
        if not subject.getFolder(folder_name).can_write(c.user):
            deny(_('You have no right to delete this folder.'), 403)
        else:
            return self._delete_folder(subject)

    @subject_action
    @ActionProtector("moderator", "root")
    def delete(self, subject):
        c.subject.deleted = c.user
        meta.Session.commit()
        redirect(request.referrer)

    @subject_action
    @ActionProtector("moderator", "root")
    def undelete(self, subject):
        c.subject.deleted = None
        meta.Session.commit()
        redirect(request.referrer)
