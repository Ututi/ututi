import PIL
from PIL import Image
import StringIO

from pylons import response
from pylons.controllers.util import abort


def serve_image(file, width=None, height=None):
    if file is not None:
        response.headers['Content-Disposition'] = 'inline'

        if width is not None or height is not None:
            img = Image.open(file.filepath())
            img = resize_image(img, width=width, height=height)
        else:
            source = open(file.filepath(), 'r')
            response.headers['Content-Type'] = file.mimetype
            response.headers['Content-Length'] = file.filesize
            return source.read()

        buffer = StringIO.StringIO()
        img.save(buffer, "PNG")
        response.headers['Content-Length'] = buffer.len
        response.headers['Content-Type'] = 'image/png'
        return buffer.getvalue()

    else:
        abort(404)


def resize_image(image, width=None, height=None):
    """Resize PIL image to fit the necessary dimensions.

    This function resizes a given PIL.Image to fit in a bounding box if
    both width and height are specified.

    If only the width or height is passed, the other dimmension is
    calculated from it. (XXX ignas - it's probably a bad idea, because
    it makes us vulnerable to malicious extra long/ extra high images)
    """
    if width is not None and height is not None:
        width = float(width)
        height = float(height)
        limit_x = width / height

        original_x = float(image.size[0]) / image.size[1]

        if limit_x > original_x:
            width = None
        elif limit_x <= original_x:
            height = None

    if width is not None:
        width = float(width)
        height = int(image.size[1] * (width / float(image.size[0])))
    elif height is not None:
        height = float(height)
        width = int(image.size[0] * (height / float(image.size[1])))

    return image.resize((int(width), int(height)), PIL.Image.ANTIALIAS)
