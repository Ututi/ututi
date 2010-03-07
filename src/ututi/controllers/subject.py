import logging
from random import Random
import string

from datetime import datetime

from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, htmlfill

from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _

from ututi.model import get_supporters
from ututi.model import meta, LocationTag, Subject, File, SimpleTag
from ututi.lib.security import ActionProtector, deny
from ututi.lib.fileview import FileViewMixin
from ututi.lib.base import BaseController, render
from ututi.lib.validators import LocationTagsValidator, TagsValidator
import ututi.lib.helpers as h

log = logging.getLogger(__name__)

def subject_action(method):
    def _subject_action(self, id, tags):
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)

        if subject is None:
            abort(404)

        c.security_context = subject
        c.object_location = subject.location
        c.subject = subject
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


class SubjectController(BaseController, FileViewMixin, SubjectAddMixin):
    """A controller for subjects."""

    @subject_action
    def home(self, subject):
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file
        c.breadcrumbs = [{'link': subject.url(),
                          'title': subject.title}]
        return render('subject/home.mako')

    def _add_form(self):
        return render('subject/add.mako')

    @ActionProtector("user")
    def add(self):
        c.ututi_supporters = get_supporters()
        return self._add_form()

    @validate(schema=NewSubjectForm, form='_add_form')
    @ActionProtector("user")
    def create(self):
        if not hasattr(self, 'form_result'):
            redirect_to(controller='subject', action='add')

        subj = self._create_subject()
        meta.Session.commit()

        if self.form_result.has_key('watch_subject'):
            c.user.watchSubject(subj)
            meta.Session.commit()
            h.flash(_('You are now watching the subject %s') % subj.title)

        redirect_to(controller='subject',
                    action='home',
                    id=subj.subject_id,
                    tags=subj.location_path)

    def _edit_form(self):
        return render('subject/edit.mako')
    @subject_action
    @ActionProtector("user")
    def edit(self, subject):
        c.breadcrumbs = [{'link': c.subject.url(),
                          'title': c.subject.title}]

        defaults = {
            'id': subject.subject_id,
            'old_location': '/'.join(subject.location.path),
            'title': subject.title,
            'lecturer': subject.lecturer,
            'tags': ', '.join([tag.title for tag in subject.tags]),
            'description': subject.description,
            }

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

        redirect_to(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path)


    @subject_action
    @validate(schema=SubjectForm, form='_edit_form')
    @ActionProtector("user")
    def update(self, subject):
        if not hasattr(self, 'form_result'):
            redirect_to(controller='subject', action='add')

        #check if we need to regenerate the id
        clash = Subject.get(self.form_result.get('location', None), subject.subject_id)
        if clash is not None and clash is not subject:
            subject.subject_id = subject.generate_new_id()


        subject.title = self.form_result['title']
        subject.lecturer = self.form_result['lecturer']
        subject.location = self.form_result['location']
        subject.description = self.form_result.get('description', None)

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', []) if len(tag.strip().lower()) < 250]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',') if len(tag.strip()) < 250]

        subject.tags = []
        for tag in tags:
            subject.tags.append(SimpleTag.get(tag))


        meta.Session.commit()

        redirect_to(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path)

    @subject_action
    @ActionProtector("user")
    def upload_file(self, subject):
        return self._upload_file(subject)

    @subject_action
    @ActionProtector("user")
    def upload_file_short(self, subject):
        return self._upload_file_short(subject)

    @subject_action
    @ActionProtector("user")
    def create_folder(self, subject):
        self._create_folder(subject)
        redirect_to(subject.url())

    @subject_action
    @ActionProtector("user")
    def delete_folder(self, subject):
        folder_name = request.params['folder']
        if not subject.getFolder(folder_name).can_write(c.user):
            deny(_('You have no right to delete this folder.'), 403)
        else:
            self._delete_folder(subject)
            redirect_to(request.referrer)

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
        redirect_to(request.referrer)

    @subject_action
    @ActionProtector("moderator", "root")
    def undelete(self, subject):
        c.subject.deleted = None
        meta.Session.commit()
        redirect_to(request.referrer)
