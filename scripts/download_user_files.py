import sys
import os
from subprocess import call


def build_path(prefix, digest):
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


def get_hash_list(connection):
    file_hashes = map(lambda row: row[0],
                      connection.execute("select files.md5 from files;"))
    return filter(bool, file_hashes)


def download_file(digest, local_prefix, remote_prefix, userhost='ututi@ututi.com'):
    remote_file = build_path(remote_prefix, digest)
    local_file = build_path(local_prefix, digest)
    call(['mkdir', '-p', '%s' % os.path.dirname(local_file)])
    return call(['scp', '%s:%s' % (userhost, remote_file), local_file])


def main():
    if len(sys.argv) < 5:
        print 'Usage: %s <config.ini> <remote_user@host> <remote_prefix> <local_prefix>'
        sys.exit(1)
    config_file = sys.argv[1]
    userhost = sys.argv[2]
    remote_prefix = sys.argv[3]
    local_prefix = sys.argv[4]

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    connection = engine.connect()
    file_hashes = get_hash_list(connection)
    for file_hash in file_hashes:
        download_file(file_hash, local_prefix, remote_prefix, userhost=userhost)

if __name__ == '__main__':
    main()
