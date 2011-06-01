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

def process_logo(value):

    if value is None:
        return

    image = Image.open(StringIO.StringIO(value))
    orig_format = image.format

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

def logo_property(logo_attr='raw_logo', inherit=False):

    def get(self):
        logo = getattr(self, logo_attr)
        if logo is None and inherit and self.parent is not None:
            return self.parent.logo # XXX assumed logo property name!
        else:
            return logo

    def set(self, value):
        setattr(self, logo_attr, process_logo(value))

    return property(get, set)
