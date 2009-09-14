import logging

from paste.fileapp import FileApp

from pylons.templating import render_mako_def
from pylons.controllers.util import abort
from pylons import request, response, c
from pylons.controllers.util import redirect_to
from pylons.controllers.util import forward

from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.model import meta, File, ContentItem
from sqlalchemy.orm.exc import NoResultFound
from pylons.i18n import _
from routes import url_for

log = logging.getLogger(__name__)


def serve_file(file):
    headers = [('Content-Disposition', 'attachment; filename="%s"' % file.filename.encode('utf-8'))]
    return forward(FileApp(file.filepath(), headers=headers))


class BasefilesController(BaseController):

    def _get(self, file):
        return serve_file(file)

    def _delete(self, file):
        meta.Session.delete(file)
        meta.Session.commit()

    def _move(self, source, file):
        source_folder = file.folder

        file.folder = request.POST['target_folder']

        if source_folder and source.getFolder(source_folder) is None:
            source.files.append(File.makeNullFile(source_folder))

        meta.Session.commit()

    def _copy(self, source, file_to_copy):
        target_id = int(request.POST['target_id'])
        target = meta.Session.query(ContentItem).filter_by(id=target_id).one()


        new_file = file_to_copy.copy()
        new_file.folder = request.POST['target_folder']

        target.files.append(new_file)
        meta.Session.commit()

        return render_mako_def('/sections/files.mako','file', file=new_file)


class FilesController(BasefilesController):
    """A controller for files. Handles listing, uploads and downloads."""

    def __before__(self):
        c.breadcrumbs = [
            {'link': url_for(controller='files', action='index'),
             'title': _('Files')}
        ]

    @ActionProtector('root')
    def index(self):
        c.files = meta.Session.query(File).all()
        return render('files.mako')

    @ActionProtector('root')
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

    @ActionProtector('root')
    def get(self, id):
        file = File.get(id)
        if file is None:
            abort(404)
        return self._get(file)

    @ActionProtector('root')
    def delete(self, id):
        file = File.get(id)
        if file is None:
            abort(404)
        return self._delete(file)
