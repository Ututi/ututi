import logging

from ututi.lib.base import BaseController, render
from pylons import c, request
from pylons.decorators import validate
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
from ututi.model import LocationTag
from ututi.model import Page
from ututi.model import meta, Subject
from routes import url_for
from sqlalchemy.orm.exc import NoResultFound
from formencode.variabledecode import NestedVariables
from formencode.foreach import ForEach
from formencode import Schema, validators, Invalid, All

log = logging.getLogger(__name__)


class LocationValidator(validators.FormValidator):

    messages = {
        'location_tag_not_found': _(u"Location tag with such name could not be found."),
    }

    def _to_python(self, form_dict, state):
        tag = LocationTag.get(form_dict['location'])
        form_dict['location'] = tag
        return form_dict

    def validate_python(self, form_dict, state):
        if form_dict['location'] is None:
            raise Invalid(self.message('location_tag_not_found', state),
                          form_dict, state)


class SubjectIdValidator(validators.FormValidator):

    messages = {
        'duplicate' : _(u"Such id already exists, choose a different one."),
    }

    def validate_python(self, form_dict, state):
        # XXX test for id matching a tag
        location = form_dict['location']
        subject = Subject.get(location, form_dict['id'])
        if subject is not None:
            raise Invalid(self.message('duplicate', state),
                          form_dict, state)


class NewSubjectForm(Schema):
    """A schema for validating new subject forms."""

    allow_extra_fields = True

    pre_validators = [NestedVariables()]

    location = ForEach(validators.String())

    title = validators.String(not_empty=True)

    msg = {'invalid' : _('The text contains invalid characters, only letters, numbers and the symbols - + _ are allowed.')}

    id = All(validators.Regex(r'^[_\+\-a-zA-Z0-9]*$',
                              messages=msg),
             validators.String(max=50, not_empty=True))

    chained_validators = [LocationValidator(),
                          SubjectIdValidator()]


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

    def _getLocation(self, **kwargs):
        location_path = []
        for i in range(5):
            title_short = kwargs.get('l%s' % i, None)
            if title_short is None:
                break
            location_path.append(title_short)
        return LocationTag.get(location_path)

    def subject_home(self, **kwargs):
        location = self._getLocation(**kwargs)
        subject_id = kwargs['id']
        subject = Subject.get(location, subject_id)
        if subject is None:
            abort(404)

        c.breadcrumbs.append({'link': url_for(controller='subject',
                                              action='subject_home',
                                              id=subject.id,
                                              **subject.location_path),
                              'title' : subject.title})
        c.subject = subject
        return render('subject_home.mako')

    def add(self):
        return render('subject/add.mako')

    @validate(schema=NewSubjectForm, form='add')
    def new_subject(self):
        title = self.form_result['title'].strip()
        id = self.form_result['id'].strip().lower()
        lecturer = self.form_result['lecturer'].strip()
        location = self.form_result['location']

        if lecturer == '':
            lecturer = None

        subj = Subject(id, title, location, lecturer)

        meta.Session.add(subj)
        meta.Session.commit()

        redirect_to(controller='subject',
                    action='subject_home',
                    id=subj.id,
                    **subj.location_path)

    def page(self, id, page_id, l0='', l1='', l2='', l3='', l4=''):
        location = LocationTag.get([l0, l1, l2, l3, l4])
        if location is None:
            abort(404)
        subject = Subject.get(location, id)
        if subject is None:
            abort(404)

        page = Page.get(int(page_id))
        if page not in subject.pages:
            abort(404)

        c.subject = subject
        c.page = page
        return render('subject/page.mako')
