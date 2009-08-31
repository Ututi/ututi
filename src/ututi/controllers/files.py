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


class BasefilesController(BaseController):

    def _get(self, file):
        response.headers['Content-Type'] = file.mimetype
        response.headers['Content-Length'] = file.filesize
        response.headers['Content-Disposition'] = 'attachment; filename=%s' % file.filename
        source = open(file.filepath(), 'r')
        return _FileIter(source)

    def _delete(self, file):
        meta.Session.delete(file)
        meta.Session.commit()

    def _move(self, source, file):
        # XXX make sure person performing this operation can do it
        # with the target object
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


class FilesController(BasefilesController):
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
        return self._get(file)

    def delete(self, id):
        try:
            file = meta.Session.query(File).filter_by(id=id).one()
        except NoResultFound:
            abort(404)
        return self._delete(file)
