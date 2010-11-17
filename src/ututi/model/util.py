import PIL
from PIL import Image
import StringIO

def process_logo(value):

    if value is None:
        return

    image = Image.open(StringIO.StringIO(value))

    width = height = 500
    if image.size[0] < width and image.size[1] < height:
        return value

    width = min(width, image.size[0])
    height = min(height, image.size[1])

    width = float(width)
    height = float(height)
    limit_x = width / height

    original_x = float(image.size[0]) / image.size[1]

    if limit_x > original_x:
        width = height * original_x
    elif limit_x <= original_x:
        height = width / original_x

    new_image = image.resize((int(width), int(height)), PIL.Image.ANTIALIAS)
    # Try saving as png
    png_buffer = StringIO.StringIO()
    new_image.save(png_buffer, "PNG")
    png_result = png_buffer.getvalue()

    # Try preserving original format (JPEG most of the time)
    orig_buffer = StringIO.StringIO()
    new_image.save(orig_buffer, image.format)
    orig_result = orig_buffer.getvalue()

    # see which one is the smallest one, resized png, resized original
    # or plain original
    size, result = min((len(png_result), png_result),
                       (len(orig_result), orig_result),
                       (len(value), value))
    return result


def logo_property():
    def get(self):
        return self.raw_logo
    def set(self, value):
        self.raw_logo = process_logo(value)
    return property(get, set)
