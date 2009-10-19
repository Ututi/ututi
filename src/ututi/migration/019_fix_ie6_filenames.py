# Fix filenames and titles that contain the full path
from sqlalchemy.sql.expression import text


def cleanupFileName(filename):
    return filename.split('\\')[-1].split('/')[-1]


def upgrade(engine):
    c = engine.connect()

    files = list(c.execute(r"select files.id, "
                           "        files.filename, "
                           "        files.title, "
                           "        content_items.created_by "
                           " from files"
                           " join content_items on content_items.id = files.id"
                           ))

    for id, filename, title, who in files:
        engine.echo = True
        c.execute(text("SET ututi.active_user TO :uid"), uid=who)
        new_filename = cleanupFileName(filename)
        new_title = cleanupFileName(title)
        if (new_filename != filename or
            new_title != title):
            c.execute(text("update files"
                           "   set title = :title,"
                           "   filename  = :filename"
                           "   where id  = :id"),
                      title=new_title,
                      filename=new_filename,
                      id=id)


def downgrade(engine):
    pass
