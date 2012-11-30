import sys
import os
from functools import partial


def build_filename(prefix, digest):
    segment = ''
    path = prefix
    for c in digest:
        segment += c
        if len(segment) > 7:
            path = os.path.join(path, segment)
            segment = ''
        if segment:
            path = os.path.join(path)
    return path


def get_file_list(connection, prefix):
    file_hashes = map(lambda row: row[0],
                      connection.execute("select files.md5 from files, content_items, tags"
                                         " where files.id = content_items.id"
                                         " and content_items.location_id = tags.id"
                                         " and tags.title_short in ('vu', 'mif');"))
    return map(partial(build_filename, prefix), filter(bool, file_hashes))


def main():
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'development.ini'
    prefix = sys.argv[2] if len(sys.argv) > 2 else '/srv/ututi.com/instance/uploads'

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    connection = engine.connect()
    for f in get_file_list(connection, prefix):
        print f

if __name__ == '__main__':
    main()
