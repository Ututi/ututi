import logging

from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode import Schema, validators, Invalid, All
from routes import url_for

from pylons import c
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _

from ututi.model import meta, LocationTag, Page, Subject
from ututi.lib.base import BaseController, render
from ututi.lib.validators import LocationTagsValidator

log = logging.getLogger(__name__)


class SubjectIdValidator(validators.FormValidator):

    messages = {
        'duplicate': _(u"Such id already exists, choose a different one."),
    }

    def validate_python(self, form_dict, state):
        # XXX test for id matching a tag
        location = LocationTag.get_by_title((form_dict['schoolsearch']))
        subject = Subject.get(location, form_dict['id'])
        if subject is not None:
            raise Invalid(self.message('duplicate', state),
                          form_dict, state)


class NewSubjectForm(Schema):
    """A schema for validating new subject forms."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    schoolsearch = All(ForEach(validators.String(strip=True)),
                                  LocationTagsValidator())

    title = validators.UnicodeString(not_empty=True, strip=True)
    lecturer = validators.UnicodeString(strip=True)

    msg = {'invalid': _('The text contains invalid characters, only letters, numbers and the symbols - + _ are allowed.')}

    id = All(validators.Regex(r'^[_\+\-a-zA-Z0-9]*$',
                              messages=msg),
             validators.String(max=50, strip=True, not_empty=True))

    chained_validators = [SubjectIdValidator()]


class SubjectController(BaseController):
    """A controller for subjects."""

    def __before__(self):
        c.breadcrumbs = [
            {'title': _('Subjects'),
             'link': url_for(controller='subject', action='index')}
            ]

    def index(self):
        c.subjects = meta.Session.query(Subject).all()
        return render('subjects.mako')

    def home(self, id, tags):
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)
        if subject is None:
            abort(404)

        c.breadcrumbs.append({'link': subject.url(),
                              'title': subject.title})
        c.subject = subject
        return render('subject/home.mako')

    def add(self):
        return render('subject/add.mako')

    @validate(schema=NewSubjectForm, form='add')
    def create(self):
        import pdb; pdb.set_trace()
        title = self.form_result['title']
        id = self.form_result['id'].lower()
        lecturer = self.form_result['lecturer']
        location = LocationTag.get_by_title(self.form_result['schoolsearch'])

        if lecturer == '':
            lecturer = None

        subj = Subject(id, title, location, lecturer)

        meta.Session.add(subj)
        meta.Session.commit()

        redirect_to(controller='subject',
                    action='home',
                    id=subj.id,
                    tags=subj.location_path)
