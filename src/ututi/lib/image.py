import PIL
from PIL import Image
import StringIO

from pylons import response
from pylons.controllers.util import abort, etag_cache
from sqlalchemy.orm.exc import NoResultFound

from ututi.lib.cache import u_cache
from ututi.model import Group, User, LocationTag, meta


def serve_logo(obj_type, obj_id, width=None, height=None, default_img_path=None):
    img_data = prepare_logo(obj_type, obj_id, width, height, default_img_path)
    if img_data is None:
        abort(404)
    response.headers['Content-Disposition'] = 'inline'
    response.headers['Content-Length'] = len(img_data)
    response.headers['Content-Type'] = 'image/png'

    # Clear the default cache headers
    del response.headers['Cache-Control']
    del response.headers['Pragma']
    response.cache_expires(seconds=3600, public=True)
    etag_cache(str(hash(img_data)))

    return img_data


@u_cache(expire=3600, query_args=False, invalidate_on_startup=True)
def prepare_logo(obj_type, obj_id, width=None, height=None, default_img_path=None):
    obj_cls = {'group': Group, 'user': User, 'locationtag': LocationTag}[obj_type]
    obj = obj_cls.get(obj_id)
    if obj is None:
        return None

    if obj.has_logo():
        return prepare_image(obj.logo, width, height)
    elif default_img_path is not None:
        stream = resource_stream("ututi", default_img_path).read()
        return prepare_image(stream, width, height)
    else:
        return None


def prepare_image(image, width=None, height=None):
    img = Image.open(StringIO.StringIO(image))
    if width is not None or height is not None:
        img = resize_image(img, width=width, height=height)
    buffer = StringIO.StringIO()
    img.save(buffer, "PNG")
    return buffer.getvalue()


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
