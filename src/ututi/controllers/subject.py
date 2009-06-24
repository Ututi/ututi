import logging

from ututi.lib.base import BaseController, render
from pylons import c
from pylons.i18n import _
from ututi.model import meta, Subject
from routes import url_for

log = logging.getLogger(__name__)

class SubjectController(BaseController):
    def __before__(self):
        c.breadcrumbs = [
            {'title' : _('Subjects'),
             'link' : url_for(controller = 'subject', action = 'index')}
            ]

    def index(self):
        c.subjects = meta.Session.query(Subject).all()
        return render('subjects.mako')
