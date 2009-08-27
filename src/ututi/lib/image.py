import PIL
from PIL import Image
import StringIO

from pylons import response
from pylons.controllers.util import abort


def serve_image(image, width=None, height=None):
    if image is not None:
        response.headers['Content-Disposition'] = 'inline'

        if width is not None or height is not None:
            img = Image.open(StringIO.StringIO(image))
            img = resize_image(img, width=width, height=height)
        else:
            response.headers['Content-Type'] = file.mimetype
            response.headers['Content-Length'] = file.filesize
            return image

        buffer = StringIO.StringIO()
        img.save(buffer, "PNG")
        response.headers['Content-Length'] = buffer.len
        response.headers['Content-Type'] = 'image/png'
        return buffer.getvalue()
    else:
        abort(404)


def resize_image(image, width=300, height=300):
    """Resize PIL image to fit the necessary dimensions.

    This function resizes a given PIL.Image to fit in a bounding box if
    both width and height are specified.

    If only the width or height is passed, the other dimmension is
    calculated from it.

    Both dimmensions are capped at 300 unless the image is not
    resized.
    """
    if width is None and height is None:
        return image

    width = width or 300
    height = height or 300

    width = min(300, int(width))
    height = min(300, int(height))

    width = float(width)
    height = float(height)
    limit_x = width / height

    original_x = float(image.size[0]) / image.size[1]

    if limit_x > original_x:
        width = height * original_x
    elif limit_x <= original_x:
        height = width / original_x

    return image.resize((int(width), int(height)), PIL.Image.ANTIALIAS)
