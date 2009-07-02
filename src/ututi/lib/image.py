from paste.fileapp import _FileIter
from pylons import response
from pylons.controllers.util import abort


def serve_image(file):
    if file is not None:
        response.headers['Content-Type'] = file.mimetype
        response.headers['Content-Length'] = file.filesize
        response.headers['Content-Disposition'] = 'attachment; filename=%s' % file.filename
        source = open(file.filepath(), 'r')
        return _FileIter(source)
    else:
        abort(404)
