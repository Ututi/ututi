import PIL
from PIL import Image
import StringIO

from sqlalchemy.types import Integer, Binary
from sqlalchemy.schema import MetaData, Table, Column
from sqlalchemy.sql.expression import select


def resize_image(img):
    """Resize an image so it's dimmensions would be less or equal to the necessary dimensions.
    """
    image = Image.open(StringIO.StringIO(img))

    width = 500
    height = 500

    if image.size[0] < width and image.size[1] < height:
        return None

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
                       (len(img), None))
    return result


def resize_logos(table, connection):
    all_logos = connection.execute(select([table.c.id, table.c.logo]))
    for id, logo in all_logos:
        if logo is None:
            continue
        logo = resize_image(logo)
        if logo is None:
            continue
        stmt = table.update().where(table.c.id == id).values(logo=logo)
        connection.execute(stmt)


def upgrade(engine):
    connection = engine.connect()

    metadata = MetaData()
    users = Table("users", metadata,
                  Column('id', Integer, primary_key=True),
                  Column('logo', Binary))
    resize_logos(users, connection)

    groups = Table("groups", metadata,
                   Column('id', Integer, primary_key=True),
                   Column('logo', Binary))
    resize_logos(groups, connection)

    tags = Table("tags", metadata,
                 Column('id', Integer, primary_key=True),
                 Column('logo', Binary))
    resize_logos(tags, connection)


def downgrade(engine):
    """XXX we do not have the downgrade path.

    We are trying to reduce the size of the database, not increase it,
    and storing a backup of all images would defeat the purpose.
    """
