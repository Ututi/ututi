import PIL
from PIL import Image
import StringIO
import urllib

def read_facebook_logo(facebook_id):
    """Attempts to read user logo from FB. Returns None on failure."""
    if not facebook_id:
        return None
    photo_url = 'https://graph.facebook.com/%s/picture?type=large' % facebook_id
    try:
        logo = urllib.urlopen(photo_url).read()
    except IOError:
        pass
    else:
        try:
            # test that image opens correctly
            Image.open(StringIO.StringIO(logo))
            return logo
        except IOError:
            pass

def _adjust_size(image):
    max_width = max_height = 500

    width, height = image.size
    if width <= max_width and height <= max_height:
        return image

    if width > max_width:
        ratio = float(max_width) / width
        width, height = width * ratio, height * ratio

    if height > max_height:
        ratio = float(max_height) / height
        width, height = width * ratio, height * ratio

    return image.resize((int(width), int(height)), PIL.Image.ANTIALIAS)

def _crop_square(image):

    width, height = image.size
    if width > height:
        x = (width - height) / 2
        box = (x, 0, x + height, height)
    else:
        y = (height - width) / 2
        box = (0, y, width, y + width)

    return image.crop(box)

def process_logo(value, crop_square=False):

    if value is None:
        return

    image = Image.open(StringIO.StringIO(value))
    orig_format = image.format

    if crop_square:
        image = _crop_square(image)

    image = _adjust_size(image)

    # Try saving as png
    png_buffer = StringIO.StringIO()
    image.save(png_buffer, "PNG")
    png_result = png_buffer.getvalue()

    # Try preserving original format (JPEG most of the time)
    orig_buffer = StringIO.StringIO()
    image.save(orig_buffer, orig_format)
    orig_result = orig_buffer.getvalue()

    # see which one is the smallest one: resized png or resized original
    size, result = min((len(png_result), png_result),
                       (len(orig_result), orig_result))
    return result

def logo_property(square=False, logo_attr='raw_logo'):
    def get(self):
        return getattr(self, logo_attr)
    def set(self, value):
        setattr(self, logo_attr, process_logo(value, square))
    return property(get, set)
