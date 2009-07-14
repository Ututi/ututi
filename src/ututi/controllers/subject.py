import logging

from ututi.lib.base import BaseController, render
from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
from ututi.model import Page
from ututi.model import meta, Subject
from routes import url_for
from sqlalchemy.orm.exc import NoResultFound
from formencode import Schema, validators, Invalid, All

log = logging.getLogger(__name__)

class UniqueIdValidator(validators.FancyValidator):
    """A validator that makes sure the group id is unique."""
    messages = {
        'duplicate' : _(u"Such id already exists, choose a different one."),
    }

    def __init__(self, model):
        self.model = model

    def _to_python(self, value, state):
        return value.strip()

    def validate_python(self, value, state):
        obj = self.model.get(value)
        if obj is not None:
            raise Invalid(self.message('duplicate', state), value, state)


class NewSubjectForm(Schema):
    """A schema for validating new subject forms."""
    allow_extra_fields = True

    title = validators.String(not_empty=True)

    msg = {'invalid' : _('The text contains invalid characters, only letters, numbers and the symbols - + _ are allowed.')}

    id = All(UniqueIdValidator(Subject),
             validators.Regex(r'^[_\+\-a-zA-Z0-9]*$',
                              messages=msg),
             validators.String(max=50, not_empty=True))


class SubjectController(BaseController):
    """A controller for subjects."""

    def __before__(self):
        c.breadcrumbs = [
            {'title' : _('Subjects'),
             'link' : url_for(controller = 'subject', action = 'index')}
            ]

    def index(self):
        c.subjects = meta.Session.query(Subject).all()
        return render('subjects.mako')

    def subject_home(self, id):
        subject = Subject.get(id)
        if subject is None:
            abort(404)

        c.breadcrumbs.append({'link': url_for(controller='subject',
                                              action='subject_home',
                                              id=subject.id),
                              'title' : subject.title})
        c.subject = subject
        return render('subject_home.mako')

    def add(self):
        return render('subject/add.mako')

    @validate(schema=NewSubjectForm, form='add')
    def new_subject(self):
        title = request.POST.get('title').strip()
        id = request.POST.get('id').strip().lower()
        lecturer = request.POST.get('lecturer').strip()
        if lecturer == '':
            lecturer = None

        subj = Subject(id, title, lecturer)
        meta.Session.add(subj)
        meta.Session.commit()

        redirect_to(controller='subject', action='subject_home', id=subj.id)

    def page(self, id, page_id):
        subject = Subject.get(id)
        if subject is None:
            abort(404)

        page = Page.get(int(page_id))
        if page not in subject.pages:
            abort(404)

        c.subject = subject
        c.page = page
        return render('subject/page.mako')
