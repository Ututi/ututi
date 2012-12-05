import os

from fabric.contrib.files import exists
from fabric.context_managers import cd
from fabric.operations import open_shell
from fabric.operations import run

from nous_deploy.services import run_as_user
from nous_deploy.services import Service
from nous_deploy.services import run_as_sudo


class Postgresql(Service):

    @property
    def BIDNIR(self):
        paths = {'9.1': "/usr/lib/postgresql/9.1/bin",
                 '8.4': "/usr/lib/postgresql/8.4/bin"}
        return paths[self.version]

    @property
    def version(self):
        return self.settings.get('version', '9.1')

    @property
    def db_port(self):
        return self.settings['port']

    @property
    def password(self):
        return self.settings['password']

    @property
    def service_path(self):
        return os.path.join("/srv", self.name)

    @property
    def cluster_path(self):
        return os.path.join(self.service_path, 'db')

    @property
    def socket_dir(self):
        return os.path.join(self.service_path, 'var', 'run')

    @property
    def sqlalchemy_url(self):
        return "postgresql://%s:%s@localhost:%d/%s" % (
            self.user, self.password, self.db_port, self.name)

    def dir(self):
        return cd(self.service_path)

    @run_as_user
    def pg_run(self, command, params=''):
        run(os.path.join(self.BIDNIR, command) + ' ' + params)

    @run_as_user
    def execute_psql(self, statement):
        with self.dir():
            run('echo "%s" | %s' % (statement, self.psql_cmd))

    @property
    def psql_cmd(self):
        return os.path.join(self.BIDNIR, 'psql') + ' -U %s -d %s -h %s -p %s' % (
            self.user, self.name, self.socket_dir, self.db_port)

    def droplang(self, lang):
        return os.path.join(self.BIDNIR, 'droplang') + ' %s -U %s -d %s -h %s -p %s' % (
            lang, self.user, self.name, self.socket_dir, self.db_port)

    @property
    def restore_cmd(self):
        return os.path.join(self.BIDNIR, 'pg_restore') + ' -U %s -d %s -h %s -p %s --no-owner' % (
            self.user, self.name, self.socket_dir, self.db_port)

    @property
    def dump_cmd(self):
        return os.path.join(self.BIDNIR, 'pg_dump') + ' {database} -U {user} -h {host} -p {port} -Fc'.format(
            user=self.user, database=self.name, host=self.socket_dir, port=self.db_port)

    @run_as_user
    def import_dump(self, path_to_dump):
        run(self.restore_cmd + ' < ' + path_to_dump)

    @run_as_sudo
    def create_cluster(self):
        run("mkdir -p %s" % self.service_path)
        run("mkdir -p %s/var/log" % self.service_path)
        run("mkdir -p %s/var/run" % self.service_path)
        run("chown -R {username}:{username} {path}".format(username=self.user,
                                                           path=self.service_path))
        with self.dir():
            self.pg_run('initdb', ' -D db -E UNICODE')

    @run_as_sudo
    def ensure_cluster(self):
        if not exists(os.path.join(self.cluster_path, 'PG_VERSION')):
            self.create_cluster()

    @run_as_user
    def createlang_plpgsql(self):
        with self.dir():
            self.pg_run('createlang plpgsql',
                        "%s -h %s -p %s" % (self.name, self.socket_dir, self.db_port))

    @run_as_user
    def create_database(self):
        with self.dir():
            self.pg_run('createdb',
                        '-E UTF8 %s -h %s -p %s' % (self.name,
                                                    self.socket_dir,
                                                    self.db_port))
            if self.version == '8.4':
                self.createlang_plpgsql()
            run('touch ' + os.path.join(self.cluster_path, 'created_%s' % self.name))

    @run_as_user
    def ensure_database(self):
        if not exists(os.path.join(self.cluster_path, 'created_%s' % self.name)):
            self.create_database()

    @run_as_user
    def set_user_password(self, user, password):
        self.execute_psql("ALTER USER %s PASSWORD '%s'" % (user, password))

    @run_as_sudo
    def prepare(self):
        # run("add-apt-repository ppa:pitti/postgresql")
        # self.server.apt_get_update(force=True)
        packages = {'9.1': "postgresql-9.1",
                    '8.4': "postgresql-8.4"}
        self.server.apt_get_install(packages[self.version])

    @run_as_sudo
    def setup(self):
        self.server.ensure_user(self.user)
        self.ensure_cluster()
        self.configure()
        self.start()
        self.ensure_database()
        self.set_user_password(self.user, self.password)

    @run_as_user
    def configure(self):
        self.upload_config_template('postgresql.conf',
                                    os.path.join(self.cluster_path, 'postgresql.conf'),
                                    {'service': self})
        self.upload_config_template('pg_hba.conf',
                                    os.path.join(self.cluster_path, 'pg_hba.conf'),
                                    {'service': self})

    @run_as_sudo
    def remove(self):
        self.stop()
        run("rm -rf " + self.service_path)

    @run_as_user
    def pg_ctl(self, command):
        log_file = os.path.join(self.service_path, 'var', 'log', 'pg.log')
        with self.dir():
            extra_options = "-o '%s'" % ' -c '.join(
                ['',
                 'unix_socket_directory={socket_dir}'.format(socket_dir=self.socket_dir)] +
                self.settings.get('extra_options', []))
            self.pg_run('pg_ctl', " -D {cluster_path} {extra_options} -l {log_file} {command}".format(
                    cluster_path=self.cluster_path,
                    extra_options=extra_options,
                    log_file=log_file,
                    command=command))

    @run_as_user
    def psql(self):
        with self.dir():
            open_shell(self.psql_cmd)

    @run_as_user
    def start(self, force=False):
        if self.version == '9.1':
            self.pg_ctl("start -w")
        else:
            self.pg_ctl("start; sleep 5")
            self.status()

    @run_as_user
    def status(self, force=False):
        self.pg_ctl("status")

    @run_as_user
    def stop(self, force=False):
        self.pg_ctl("stop -m f || true")
