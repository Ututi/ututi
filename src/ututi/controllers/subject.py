import logging

from ututi.lib.base import BaseController, render
from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
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

    title = validators.String(not_empty = True)

    msg = {'invalid' : _('The text contains invalid characters, only letters, numbers and the symbols - + _ are allowed.')}

    text_id = All(UniqueIdValidator(Subject), validators.Regex(r'^[_\+\-a-zA-Z0-9]*$', messages=msg), validators.String(max=20))


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
        try:
            id = int(id)
            #the id is a numeric id
            subject = meta.Session.query(Subject).filter_by(id = id).one()

        except:
            #either the id was not numeric or nothing was found
            id = str(id)
            try:
                subject = meta.Session.query(Subject).filter_by(text_id = id).one()
            except NoResultFound:
                abort(404)

        #if the subject has a text id, we redirect using it
        if subject.text_id is not None and subject.text_id != str(id):
            redirect_to(controller='subject', action='subject_home', id=subject.text_id)



        c.breadcrumbs.append({'link': url_for(controller='subject',
                                              action='subject_home',
                                              id=subject.text_id is not None and subject.text_id or subject.id),
                              'title' : subject.title})
        c.subject = subject
        return render('subject_home.mako')

    def add(self):
        return render('subject/add.mako')

    @validate(schema=NewSubjectForm, form='add')
    def new_subject(self):
        title = request.POST.get('title').strip()
        text_id = request.POST.get('text_id', None).strip().lower()
        if text_id == '':
            text_id = None
        lecturer = request.POST.get('lecturer', None).strip()
        if lecturer == '':
            lecturer = None

        subj = Subject(title, text_id, lecturer)
        meta.Session.add(subj)
        meta.Session.commit()

        redirect_to(controller='subject', action='subject_home', id=subj.id)
