import sys
import os


def delete_locations(conn, keep=[]):
    conn.execute("begin;")
    conn.execute("delete from group_mailing_list_messages;")
    conn.execute("delete from payments;")
    conn.execute("delete from groups;")
    conn.execute("delete from tags where tag_type = 'location' and title_short not in (%s);" % ', '.join(keep))
    conn.execute("commit;")


def main():
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'development.ini'

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    connection = engine.connect()
    delete_locations(connection, keep=["'vu'", "'mif'"])

if __name__ == '__main__':
    main()
