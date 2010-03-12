import logging
import mimetypes
import re

from paste.fileapp import FileApp

from pylons.templating import render_mako_def
from pylons.controllers.util import abort
from pylons import url
from pylons import request, response, c
from pylons.controllers.util import redirect_to
from pylons.controllers.util import forward

from ututi.lib.security import deny
from ututi.lib.security import is_root
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.model import meta, File, ContentItem
from sqlalchemy.orm.exc import NoResultFound
from pylons.i18n import _
from routes import url_for

log = logging.getLogger(__name__)


def serve_file(file):
    headers = [('Content-Disposition', 'attachment; filename="%s"' % file.filename.encode('utf-8'))]
    content_type, content_encoding = mimetypes.guess_type(file.filename.encode('utf-8'))
    kwargs = {'content_type': content_type}
    if content_type in ['image/png', 'image/jpeg']:
        headers = [('Content-Disposition', 'inline; filename="%s"' % file.filename.encode('utf-8'))]
    return forward(FileApp(file.filepath(), headers=headers, **kwargs))


class BasefilesController(BaseController):

    def _get(self, file):
        if file.deleted is not None or file.isNullFile():
            abort(404)
        if c.user:
            c.user.download(file)
            meta.Session.commit()
        return serve_file(file)

    def _delete(self, file):
        file.deleted = c.user
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

        return render_mako_def('/sections/files.mako','file', file=new_file, new_file=True)


class FilesController(BasefilesController):
    """A controller for files. Handles listing, uploads and downloads."""

    def __before__(self):
        c.breadcrumbs = [
            {'link': url_for(controller='files', action='index'),
             'title': _('Files')}
        ]

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

        redirect_to(controller='admin', action='files')

    def get(self, id):
        if isinstance(id, basestring):
            id = re.search(r"\d*", id).group()

        if not id:
            abort(404)

        file = File.get(id)
        if file is None:
            abort(404)
        if file.parent is not None:
            redirect_to(file.url())
        elif is_root(c.user):
            return self._get(file)
        else:
            c.login_form_url = url(controller='home',
                                   action='login',
                                   came_from=file.url())
            deny(_('You have no right to download this file.'), 403)

    @ActionProtector('root')
    def delete(self, id):
        file = File.get(id)
        if file is None:
            abort(404)
        return self._delete(file)
