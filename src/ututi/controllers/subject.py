import logging

from ututi.lib.base import BaseController, render
from pylons import c
from pylons.controllers.util import redirect_to, abort
from pylons.i18n import _
from ututi.model import meta, Subject
from routes import url_for
from sqlalchemy.orm.exc import NoResultFound

log = logging.getLogger(__name__)

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
