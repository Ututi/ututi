# XXX Work in progress
import sys
import os

from sqlalchemy.ext.sqlsoup import Session
from pprint import pprint

# catdoc
# catppt
# xls2csv
# antiword
# pdftotext

def index_10_stuffs(engine):
    connection = engine.connect()
    trans = connection.begin()
    session = Session(bind=connection)

    res = session.execute("""select files.id, files.md5, files.mimetype
                    from files left join content_items on files.id = content_items.id where files.indexed_on is NULL order by content_items.created_on limit :count""", {'count': 10})
    for fid, md5, content_type in res:
        print fid, md5, content_type

    # statement = """update files set content = 'teext cooontent'
    #             set indexed_on = (now() at time zone 'UTC')
    #             where file_id = 1122"""
    # connection.execute(statement)

    session.commit()
    session.close()
    trans.commit()


def main():
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'development.ini'
    config_name = 'config:%s' % config_file

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    index_10_stuffs(engine)
