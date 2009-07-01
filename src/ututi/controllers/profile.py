import logging

from sqlalchemy.orm.exc import NoResultFound
from paste.fileapp import _FileIter
from pylons import response
from pylons.controllers.util import abort

from ututi.lib.base import BaseController

from ututi.model import meta, User

log = logging.getLogger(__name__)


class ProfileController(BaseController):

    def logo(self, id):
        try:
            user = meta.Session.query(User).filter_by(id = id).one()
        except NoResultFound:
            abort(404)

        file = user.logo
        if file is not None:
            response.headers['Content-Type'] = file.mimetype
            response.headers['Content-Length'] = file.filesize
            response.headers['Content-Disposition'] = 'attachment; filename=%s' % file.filename
            source = open(file.filepath(), 'r')
            return _FileIter(source)
        else:
            abort(404)
