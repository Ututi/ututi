import PIL
from PIL import Image
import StringIO

from pylons import response
from pylons.controllers.util import abort


def serve_image(file, width=None, height=None):
    if file is not None:
        response.headers['Content-Disposition'] = 'inline'


        if width is not None and height is not None:
            width = int(width)
            height = int(height)

            img = Image.open(file.filepath())
            if width < height:
                if img.size[0] >= img.size[1]:
                    img = resize_image(img, width=width)
                else:
                    img = resize_image(img, height=height)
            else:
                if img.size[0] > img.size[1]:
                    img = resize_image(img, height=height)
                else:
                    img = resize_image(img, width=width)
        elif width is not None:
            width = int(width)

            img = Image.open(file.filepath())
            img = resize_image(img, width=width)
        elif height is not None:
            height = int(height)

            img = Image.open(file.filepath())
            img = resize_image(img, height=height)
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
    if width is not None:
        height = int(image.size[1] * (width / float(image.size[0])))
    elif height is not None:
        width = int(image.size[0] * (height / float(image.size[1])))

    return image.resize((width, height), PIL.Image.ANTIALIAS)
