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

from sqlalchemy.sql.expression import or_, and_

from ututi.model import SearchItem
from ututi.model import meta, LocationTag, Subject, File, SimpleTag
from ututi.model.users import Teacher
from ututi.lib.security import ActionProtector, deny, check_crowds, is_university_member, is_department_member
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
    items = [
        {'title': _("Info"),
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
    if c.user and c.subject.post_discussion_perm == 'everyone' or check_crowds(['teacher', 'moderator'], c.user):
        items.append({'title': _("Discussions"),
                      'name': 'discussions',
                      'link': c.subject.url(action='feed', filter='discussions')})
    return items


@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def find_similar_subjects(location_id, id, n=5):
    """Find 5 similar subjects to the one given."""
    location = LocationTag.get(location_id)
    subject = Subject.get(location, id)

    def filter_out(query):
        return query.filter(SearchItem.content_item_id != subject.id)

    results = search(text=subject.title, obj_type='subject', disjunctive=False, limit=n, extra=filter_out, language=location.language)
    if not results:
        results = search(text=subject.title,
                obj_type='subject',
                tags=subject.location.hierarchy(),
                disjunctive=True,
                limit=5,
                extra=filter_out,
                rank_cutoff=0.1,
                language=location.language)
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
        c.similar_subjects = find_similar_subjects(location.id, id)
        c.tabs = subject_menu_items()
        c.breadcrumbs = [{'link': subject.url(), 'title': subject.title}]
        c.theme = subject.location.get_theme()
        return method(self, subject)
    return _subject_action


def subject_privacy(method):
    def _protected_action(self, *args, **kwargs):
        if not check_crowds(['subject_accessor'], c.user, c.subject):
            location_link = ((c.subject.location.url(), ' '.join(c.subject.location.full_title_path))
                             if c.subject.visibility == 'department_members'
                             else (c.subject.location.root.url(), c.subject.location.root.title))
            request.environ['ututi.access_denied_reason'] = h.literal(_('Only %(location)s members can access see this subject.')
                                                                      % dict(location=h.link_to(location_link[1], location_link[0])))
            abort(403)
        c.user_can_edit_settings = c.user and (c.subject.edit_settings_perm == 'everyone' or check_crowds(['teacher', 'moderator'], c.user))
        c.user_can_post_discussions = c.user and (c.subject.post_discussion_perm == 'everyone' or check_crowds(['teacher', 'moderator'], c.user))
        return method(self, *args, **kwargs)
    return _protected_action


class SubjectForm(Schema):
    """A schema for validating new subject forms."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
                    LocationTagsValidator())

    title = validators.UnicodeString(not_empty=True, strip=True)
    lecturer = validators.UnicodeString(strip=True)
    subject_visibility = validators.OneOf(['everyone', 'department_members', 'university_members'], if_missing=None)
    subject_edit = validators.OneOf(['everyone', 'teachers_and_admins'], if_missing=None)
    subject_post_discussions = validators.OneOf(['everyone', 'teachers'], if_missing=None)
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


class NewSubjectForm(Schema):
    allow_extra_fields = True
    pre_validators = [NestedVariables()]
    location = Pipe(ForEach(validators.UnicodeString(strip=True, max=250)),
                    LocationTagsValidator())
    title = validators.UnicodeString(strip=True)
    lecturer = validators.UnicodeString(strip=True)


class SubjectAddMixin(object):

    def _create_subject(self):
        title = self.form_result['title']
        id = ''.join(Random().sample(string.ascii_lowercase, 8))  # use random id first
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
        from ututi.lib.wall import generic_events_query
        evts_generic = generic_events_query()

        t_evt = meta.metadata.tables['events']
        t_wall_posts = meta.metadata.tables['wall_posts']
        query = evts_generic\
             .where(or_(t_evt.c.object_id == c.subject.id,
                             t_wall_posts.c.subject_id == c.subject.id))

        if getattr(self, 'feed_filter', None) == u'discussions':
            query = query.where(t_evt.c.event_type=='subject_wall_post')

        return query


class SubjectController(BaseController, FileViewMixin, SubjectAddMixin, SubjectWallMixin):
    """A controller for subjects."""

    @subject_action
    @subject_privacy
    def home(self, subject):
        if c.user:
            blank_subject = not subject.pages and not subject.n_files(include_deleted=False)
            if not (subject.description or blank_subject) or subject in c.user.watched_subjects:
                redirect(subject.url(action='feed'))
        c.current_tab = 'info'
        return render('subject/info.mako')

    @subject_action
    @subject_privacy
    def info(self, subject):
        c.current_tab = 'info'
        return render('subject/info.mako')

    @subject_action
    @subject_privacy
    def files(self, subject):
        c.current_tab = 'files'
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file
        return render('subject/home_files.mako')

    @subject_action
    @subject_privacy
    def pages(self, subject):
        c.current_tab = 'pages'
        return render('subject/notes.mako')

    @subject_action
    @subject_privacy
    def feed(self, subject):
        c.current_tab = 'feed'
        feed_filter = request.params.get('filter')
        if feed_filter in (u'discussions',):
            c.current_tab = feed_filter
            self.feed_filter = feed_filter
        self._set_wall_variables()
        return render('subject/feed.mako')

    def _add_form(self):
        return render('subject/add.mako')

    @ActionProtector("user")
    def add(self):
        defaults = dict([('location-%d' % n, tag)
                         for n, tag in enumerate(c.user.location.hierarchy())])
        c.preset_location = c.user.location
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
        search_params['language'] = location.language

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
        if c.user.is_teacher and c.user.teacher_verified:
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

        if c.user.is_teacher:
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
        c.notabs = True
        c.show_permission_settings = check_crowds(["teacher", "moderator", "root"], c.user, c.subject)
        return render('subject/edit.mako')

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def edit(self, subject):
        if subject.edit_settings_perm != 'everyone' and not check_crowds(['teacher', 'moderator'], c.user, subject):
            abort(403)

        defaults = {
            'id': subject.subject_id,
            'old_location': '/'.join(subject.location.path),
            'title': subject.title,
            'lecturer': subject.lecturer,
            'tags': ', '.join([tag.title for tag in subject.tags]),
            'description': subject.description,
            'subject_visibility': subject.visibility,
            'subject_edit': subject.edit_settings_perm,
            'subject_post_discussions': subject.post_discussion_perm
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
    @subject_privacy
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
    @subject_privacy
    @ActionProtector("teacher")
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
    @subject_privacy
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
    @subject_privacy
    @ActionProtector("moderator")
    def teacher_assignment(self, subject):
        c.notabs = True
        c.teachers = meta.Session.query(Teacher).filter(Teacher.location==subject.location).all()
        return render('subject/assign_teacher.mako')

    @subject_action
    @subject_privacy
    @ActionProtector("moderator")
    def teacher(self, subject):
        command = request.params.get('command')
        teacher_id = int(request.params.get('teacher_id'))
        teacher = Teacher.get_byid(teacher_id)
        if command == 'assign':
            teacher.teach_subject(c.subject)
        elif command == 'remove':
            teacher.unteach_subject(c.subject)
        meta.Session.add(teacher)
        meta.Session.commit()
        redirect(c.subject.url(action='teacher_assignment'))


    @subject_action
    @subject_privacy
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

        # update subject permissions
        if check_crowds(["teacher", "moderator", "root"], c.user, subject) and 'subject_visibility' in self.form_result:
            subject.visibility = self.form_result['subject_visibility']
            subject.edit_settings_perm = self.form_result['subject_edit']
            subject.post_discussion_perm = self.form_result['subject_post_discussions']
            # remove subject from watched list for users who can't view subject anymore
            if subject.visibility != 'everyone':
                crowd_fn = is_university_member if subject.visibility == 'university_members' else is_department_member
                for watcher in subject.watching_users:
                    if not crowd_fn(watcher.user, subject):
                        watcher.user.unwatchSubject(subject)

        meta.Session.commit()

        redirect(url(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path))

    @subject_action
    @subject_privacy
    @set_login_url_to_referrer
    @ActionProtector("user")
    def upload_file(self, subject):
        return self._upload_file(subject)

    @subject_action
    @subject_privacy
    @set_login_url_to_referrer
    @ActionProtector("user")
    def upload_file_short(self, subject):
        return self._upload_file_short(subject)

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def create_folder(self, subject):
        self._create_folder(subject)
        redirect(subject.url())

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def delete_folder(self, subject):
        folder_name = request.params['folder']
        if not subject.getFolder(folder_name).can_write(c.user):
            deny(_('You have no right to delete this folder.'), 403)
        else:
            self._delete_folder(subject)
            redirect(request.referrer)

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def js_create_folder(self, subject):
        return self._create_folder(subject)

    @subject_action
    @subject_privacy
    @ActionProtector("user")
    def js_delete_folder(self, subject):
        folder_name = request.params['folder']
        if not subject.getFolder(folder_name).can_write(c.user):
            deny(_('You have no right to delete this folder.'), 403)
        else:
            return self._delete_folder(subject)

    @subject_action
    @subject_privacy
    @ActionProtector("moderator", "root")
    def delete(self, subject):
        c.subject.deleted = c.user
        meta.Session.commit()
        redirect(request.referrer)

    @subject_action
    @subject_privacy
    @ActionProtector("moderator", "root")
    def undelete(self, subject):
        c.subject.deleted = None
        meta.Session.commit()
        redirect(request.referrer)
