import sys
import os


def delete_groups(conn):
    conn.execute("begin;")
    conn.execute("delete from group_mailing_list_messages;")
    conn.execute("delete from payments;")
    conn.execute("delete from groups;")
    conn.execute("commit;")


def delete_locations(conn, keep=[]):
    conn.execute("begin;")
    conn.execute("delete from tags where tag_type = 'location' and title_short not in (%s);" % ', '.join(keep))
    conn.execute("commit;")


def delete_files(conn, keep=[]):
    conn.execute("begin;")
    conn.execute("delete from content_items using files, tags where files.id = content_items.id"
                 " and content_items.location_id = tags.id and (tags.title_short not in (%s)"
                 "     or content_items.deleted_on is not null);" % ', '.join(keep))
    conn.execute("delete from files using content_items where files.id = content_items.id and content_items.location_id is null;")
    conn.execute("commit")


def main():
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'development.ini'

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    connection = engine.connect()
    delete_groups(connection)
    delete_locations(connection, keep=["'vu'", "'mif'"])
    delete_files(connection, keep=["'vu'", "'mif'"])

if __name__ == '__main__':
    main()
