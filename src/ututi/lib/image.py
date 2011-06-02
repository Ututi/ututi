import PIL
from PIL import Image
import StringIO

from pkg_resources import resource_stream

from pylons import response
from pylons.controllers.util import abort

from ututi.lib.cache import u_cache
from ututi.model import Group, User, LocationTag, Book, \
        UserRegistration, Theme


def serve_logo(obj_type, obj_id=None, width=None, height=None,
               default_img_path=None, cache=True, square=False):
    if cache:
        img_data = prepare_logo_cached(obj_type, obj_id, width, height, default_img_path, square)
    else:
        img_data = prepare_logo(obj_type, obj_id, width, height, default_img_path, square)

    if img_data is None:
        abort(404)
    response.headers['Content-Disposition'] = 'inline'
    response.headers['Content-Length'] = len(img_data)
    response.headers['Content-Type'] = 'image/png'

    if cache:
        # Clear the default cache headers
        del response.headers['Cache-Control']
        del response.headers['Pragma']
        response.cache_expires(seconds=3600, public=True)

    return img_data


@u_cache(expire=3600, query_args=False, invalidate_on_startup=True)
def prepare_logo_cached(obj_type, obj_id, width=None, height=None, default_img_path=None, square=False):
    return prepare_logo(obj_type, obj_id, width=width, height=height, default_img_path=default_img_path, square=square)


def prepare_logo(obj_type, obj_id, width=None, height=None, default_img_path=None, square=False):
    obj = None
    if obj_id is not None:
        if obj_type == 'user':
            obj = User.get_global(obj_id)
        else:
            obj_types = {
                'book': Book,
                'group': Group,
                'locationtag': LocationTag,
                'registration': UserRegistration,
                'theme': Theme,
            }
            obj_cls = obj_types[obj_type]
            obj = obj_cls.get(obj_id)

    if obj is not None and obj.has_logo():
        return prepare_image(obj.logo, width, height, square)
    elif default_img_path is not None:
        stream = resource_stream("ututi", default_img_path).read()
        return prepare_image(stream, width, height, square)
    else:
        return None


def prepare_image(image, width=None, height=None, square=False):
    img = Image.open(StringIO.StringIO(image))
    if square:
        img = crop_square(img, width)
    elif width is not None or height is not None:
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

    max_width = min(300, int(width))
    max_height = min(300, int(height))

    width, height = image.size # actual size

    ratio = float(max_width) / width
    width, height = width * ratio, height * ratio

    if height > max_height:
        ratio = float(max_height) / height
        width, height = width * ratio, height * ratio

    return image.resize((int(width), int(height)), PIL.Image.ANTIALIAS)

def crop_square(image, size=None):
    """Crop PIL image to square of specified size by
    removing some width or height.

    The result image is centered.

    Size is capped at 300.
    """
    width, height = image.size

    if size is None:
        size = min(width, height)

    size = min(300, int(size))

    if width > height:
        ratio = float(size) / height
        width, height = int(width * ratio), int(height * ratio)
        x = (width - height) / 2
        box = (x, 0, x + height, height)
    else:
        ratio = float(size) / width
        width, height = int(width * ratio), int(height * ratio)
        y = (height - width) / 2
        box = (0, y, width, y + width)

    return image.resize((width, height), PIL.Image.ANTIALIAS).crop(box)
