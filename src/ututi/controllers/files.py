import logging

from pylons.controllers.util import abort
from pylons import request, response, c
from pylons.controllers.util import redirect_to
from paste.fileapp import _FileIter

from ututi.lib.base import BaseController, render
from ututi.model import meta, File, LocationTag, Subject, Group
from sqlalchemy.orm.exc import NoResultFound
from pylons.i18n import _
from routes import url_for

log = logging.getLogger(__name__)


class FilesController(BaseController):
    """A controller for files. Handles listing, uploads and downloads."""

    def __before__(self):
        c.breadcrumbs = [
            {'link': url_for(controller='files', action='index'),
             'title': _('Files')}
        ]

    def index(self):
        c.files = meta.Session.query(File).all()

        return render('files.mako')

    def upload(self):
        title = request.POST['title']
        description = request.POST['description']
        file = request.POST['upload']

        if file is not None and file != '':
            f = File(file.filename, title, mimetype=file.type)
            f.store(file.file)

            meta.Session.add(f)
            meta.Session.commit()

        redirect_to(controller='files', action='index')

    def get(self, id):
        try:
            file = meta.Session.query(File).filter_by(id=id).one()
        except NoResultFound:
            abort(404)

        response.headers['Content-Type'] = file.mimetype
        response.headers['Content-Length'] = file.filesize
        response.headers['Content-Disposition'] = 'attachment; filename=%s' % file.filename
        source = open(file.filepath(), 'r')
        return _FileIter(source)

    def delete(self, id):
        try:
            file = meta.Session.query(File).filter_by(id=id).one()
        except NoResultFound:
            abort(404)
        meta.Session.delete(file)
        meta.Session.commit()

    def move(self, id):
        try:
            file = meta.Session.query(File).filter_by(id=id).one()
        except NoResultFound:
            abort(404)

        source_type = request.POST['source_type']
        if source_type == 'group':
            source = Group.get(request.POST['source_id'])
        else:
            id = int(request.POST['source_location'])
            location = meta.Session.query(LocationTag).filter_by(id=id).one()
            source = Subject.get(location, request.POST['source_id'])

        target_type = request.POST['target_type']
        if target_type == 'group':
            target = Group.get(request.POST['target_id'])
        else:
            id = int(request.POST['target_location'])
            location = meta.Session.query(LocationTag).filter_by(id=id).one()
            target = Subject.get(location, request.POST['target_id'])

        source_folder = file.folder

        if source is not target:
            source.files.remove(file)
            target.files.append(file)
        file.folder = request.POST['target_folder']

        if source_folder and source.getFolder(source_folder) is None:
            source.files.append(File.makeNullFile(source_folder))

        meta.Session.commit()
