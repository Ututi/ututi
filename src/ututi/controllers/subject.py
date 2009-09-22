import logging
from random import Random
import string

from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode.compound import Pipe
from formencode import Schema, validators, Invalid

from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _

from ututi.model import meta, LocationTag, Subject, File, SimpleTag
from ututi.lib.security import ActionProtector
from ututi.lib.fileview import FileViewMixin
from ututi.lib.base import BaseController, render
from ututi.lib.validators import LocationTagsValidator
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

class SubjectIdValidator(validators.FormValidator):

    messages = {
        'duplicate': _(u"Such id already exists, choose a different one."),
    }

    def validate_python(self, form_dict, state):
        old_subject = Subject.get(LocationTag.get(form_dict.get('old_location', '')),
                                  form_dict.get('id', 0))
        # XXX test for id matching a tag
        location = form_dict['location']
        subject = Subject.get(location, form_dict['id'])
        if subject is not None and not subject is old_subject:
            raise Invalid(self.message('duplicate', state),
                          form_dict, state)


class SubjectForm(Schema):
    """A schema for validating new subject forms."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    location = Pipe(ForEach(validators.String(strip=True)),
                    LocationTagsValidator())

    title = validators.UnicodeString(not_empty=True, strip=True)
    lecturer = validators.UnicodeString(strip=True)


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

    @ActionProtector("root")
    def index(self):
        c.subjects = meta.Session.query(Subject).all()
        return render('subjects.mako')

    @subject_action
    def home(self, subject):
        file_id = request.GET.get('serve_file')
        file = File.get(file_id)
        c.serve_file = file
        c.breadcrumbs = [{'link': subject.url(),
                              'title': subject.title}]
        return render('subject/home.mako')

    @ActionProtector("user")
    def add(self):
        return render('subject/add.mako')

    @validate(schema=NewSubjectForm, form='add')
    @ActionProtector("user")
    def create(self):
        if not hasattr(self, 'form_result'):
            redirect_to(controller='subject', action='add')

        subj = self._create_subject()
        meta.Session.commit()

        redirect_to(controller='subject',
                    action='home',
                    id=subj.subject_id,
                    tags=subj.location_path)

    @subject_action
    @ActionProtector("user")
    def edit(self, subject):
        c.breadcrumbs = [{'link': c.subject.url(),
                              'title': c.subject.title}]
        c.subject.tags_list = ', '.join([tag.title for tag in c.subject.tags])
        return render('subject/edit.mako')

    @subject_action
    @ActionProtector("user")
    def watch(self, subject):
        if not c.user.watches(subject):
            c.user.watchSubject(subject)
            h.flash(_("The subject has been added to your watched subjects list."))
        else:
            c.user.ignoreSubject(subject)
            h.flash(_("The subject has been removed from your watched subjects list."))

        meta.Session.commit()

        redirect_to(controller='subject',
                    action='home',
                    id=subject.subject_id,
                    tags=subject.location_path)


    @validate(schema=SubjectForm, form='edit')
    @subject_action
    @ActionProtector("user")
    def update(self, subject):

        #check if we need to regenerate the id
        clash = Subject.get(self.form_result.get('location', None), subject.subject_id)
        if clash is not None and clash is not subject:
            subject.subject_id = subject.generate_new_id()


        subject.title = self.form_result['title']
        subject.lecturer = self.form_result['lecturer']
        subject.location = self.form_result['location']
        subject.description = self.form_result.get('description', None)

        #check to see what kind of tags we have got
        tags = [tag.strip().lower() for tag in self.form_result.get('tagsitem', [])]
        if tags == []:
            tags = [tag.strip().lower() for tag in self.form_result.get('tags', '').split(',')]

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
        redirect_to(request.referrer)

    @subject_action
    @ActionProtector("moderator", "root")
    def delete_folder(self, subject):
        self._delete_folder(subject)
        redirect_to(request.referrer)

    @subject_action
    @ActionProtector("user")
    def js_create_folder(self, subject):
        return self._create_folder(subject)

    @subject_action
    @ActionProtector("moderator", "root")
    def js_delete_folder(self, subject):
        return self._delete_folder(subject)
