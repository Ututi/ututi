import logging

from pylons.controllers.util import abort
from pylons import request, response, c
from pylons.controllers.util import redirect_to
from paste.fileapp import _FileIter

from ututi.lib.base import BaseController, render
from ututi.model import meta, File
from sqlalchemy.orm.exc import NoResultFound

log = logging.getLogger(__name__)

class FilesController(BaseController):
    def index(self):
        c.files = meta.Session.query(File).all()
        return render('files.mako')

    def upload(self):
        title = request.POST['title']
        description = request.POST['description']
        file = request.POST['upload']

        if file is not None and file != '':
            f = File(file.filename, title, mimetype=file.type)
            f.store(file.filename, file.file)

            meta.Session.add(f)
            meta.Session.commit()

        redirect_to(controller='files', action='index')

    def get(self, id):
        try:
            file = meta.Session.query(File).filter_by(id = id).one()
        except NoResultFound:
            abort(404)

        response.headers['Content-Type'] = file.mimetype
        response.headers['Content-Length'] = file.filesize
        response.headers['Content-Disposition'] = 'attachment; filename=%s' % file.filename
        source = open(file.filepath(), 'r')
        return _FileIter(source)
