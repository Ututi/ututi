import os
import pkg_resources

from StringIO import StringIO
from nous_deploy.services import Service
from nous_deploy.services import run_as_user
from nous_deploy.services import run_as_sudo
from fabric.utils import warn
from fabric.context_managers import settings
from fabric.context_managers import prefix
from fabric.context_managers import settings
from fabric.context_managers import cd
from fabric.contrib.files import sed
from fabric.contrib.files import exists
from fabric.contrib.files import append
from fabric.operations import get
from fabric.operations import put
from fabric.api import run


class VUtuti(Service):

    default_settings = dict(
        google_tracker = '',
        name='vututi',

        srv = '/srv',

        # site dirs
        site_dir = '{srv}/{name}',
        package_dir = '{site_dir}/packages',
        package_tmp_dir = '{package_dir}/tmp',
        build_dir = '{site_dir}/builds',
        backups_dir = '{site_dir}/backups',
        scripts_dir = '{site_dir}/bin/',

        # instance dirs
        instance_dir = '{site_dir}/instance',
        instance_code_dir = '{instance_dir}/code',
        static_dir = '{instance_code_dir}/src/ututi/public',
        cache_dir = '{instance_code_dir}/cache',
        session_dir = '{instance_dir}/cache/sessions',
        upload_dir = '{instance_dir}/uploads',
        log_dir = '{instance_dir}/log',

        # buildout_dirs
        buildout_dir = '{site_dir}/buildout',
        buildout_cache = '{buildout_dir}/buildout/cache',
        buildout_extends = '{buildout_dir}/buildout/extends',
        buildout_eggs = '{buildout_dir}/buildout/eggs',

        log_prefix = '')

    @property
    def port(self):
        return self.settings['port']

    @property
    def host_name(self):
        return self.settings['host_name']

    @property
    def static_prefix(self):
        return 'static'

    @property
    def static_dir(self):
        return self.settings.static_dir

    @run_as_sudo
    def prepare(self):
        run('apt-get remove sendmail -y')
        self.server.apt_get_install(' '.join([
                "build-essential",
                "enscript",
                "libfreetype6-dev",
                # "libjpeg62-dev",
                "liblcms1-dev",
                "libpq-dev",
                "libsane-dev",
                "libxml2-dev",
                "libxslt1-dev",
                "myspell-en-gb",
                "myspell-lt",
                "myspell-pl",
                "postgresql",
                "python-all",
                "python-all-dbg",
                "python-all-dev",
                "python-geoip",
                "python-pyrex",
                "python-setuptools",
                "uuid-dev",
                "zlib1g-dev",
                "supervisor",
                "postfix"
                ]))
        package = "ututi-pg-dictionaries_1.0_all.deb"
        target_filename = os.path.join(self.server.getHomeDir('root'), package)
        put(pkg_resources.resource_filename("nous_deploy.vututi", package),
            target_filename)
        run("dpkg -i %s" % target_filename)

        self.server.apt_get_install('python-software-properties')
        run('add-apt-repository ppa:fkrull/deadsnakes -y')
        run('apt-get update')
        self.server.apt_get_install('python2.6 python2.6-dev')
        # run("apt-get build-dep python-psycopg2 python-imaging")
        # apt-get remove python-egenix-mx-base-dev

    @run_as_user
    def update_release_ini(self):
        self.upload_config_template('release.ini',
                                    os.path.join(self.settings.instance_dir, 'release.ini'),
                                    {'service': self})

    @run_as_sudo
    def configure(self):
        self.server.nginx_configure_site(self)
        self.upload_config_template('ututi_supervisord.conf',
                                    '/etc/supervisor/conf.d/%s.conf' % self.name,
                                    {'service': self})
        self.update_release_ini()
        run('supervisorctl reload')

    @property
    def database(self):
        return self.server.getService(self.settings['database'])

    @property
    def sqlalchemy_url(self):
        return self.database.sqlalchemy_url

    @run_as_user
    def _make_backups_dir(self):
        run('mkdir -p %s' % self.settings.backups_dir)

    @run_as_sudo
    def create_site_dirs(self):
        for directory in [self.settings.package_dir,
                          self.settings.package_tmp_dir,
                          self.settings.build_dir,
                          self.settings.scripts_dir,
                          self.settings.buildout_cache,
                          self.settings.buildout_extends,
                          self.settings.buildout_eggs,
                          self.settings.buildout_dir,
                          self.settings.site_dir]:
            run('mkdir -p %s' % directory)
            run('chown -R %s:%s %s' % (self.user, self.user, directory))
        self._make_backups_dir()

    @run_as_user
    def upload_release(self, release):
        put(release, self.settings.package_dir)

    def dir(self):
        return cd(self.settings.instance_dir)

    @run_as_user
    def _make_upload_dir(self):
        """XXX only here because root can't access vututi mount on the production server"""
        run("mkdir -p %s" % self.settings.upload_dir)

    @run_as_sudo
    def ensure_instance_dirs(self):
        run("mkdir -p %s" % self.settings.instance_dir)
        with self.dir():
            for directory in [self.settings.session_dir,
                              self.settings.session_dir,
                              self.settings.log_dir]:
                run('mkdir -p %s' % directory)
                run('chown -R %s:%s %s' % (self.user, self.user, directory))
        run('chown -R %s:%s %s' % (self.user, self.user, self.settings.instance_dir))
        self._make_upload_dir()


    @run_as_user
    def getLastReleaseDir(self):
        # XXX should not depend on self.name unless build ensures that
        release_file = run("ls %s | sort | tail -1" % (self.settings.build_dir)).strip()
        return os.path.join(self.settings.build_dir, release_file)

    @run_as_user
    def getNextReleaseIfReady(self, release_dir=None):
        release_dir = release_dir or self.getLastReleaseDir()
        if exists(os.path.join(release_dir, 'READY')):
            return release_dir

    @run_as_user
    def link_release(self, release_dir=None):
        release_dir = self.getNextReleaseIfReady(release_dir)
        if release_dir:
            run("rm -f %s" % self.settings.instance_code_dir)
            run("ln -s %s %s" % (release_dir, self.settings.instance_code_dir))
        else:
            warn("Release is not ready yet.")

    @run_as_user
    def clear_database(self):
        self.server.getService(self.database).execute_psql('drop schema public cascade')
        self.server.getService(self.database).droplang('plpgsql')
        self.server.getService(self.database).execute_psql('create schema public')

    @run_as_user
    def reset_database(self):
        self.clear_database()
        with self.dir():
            run("rm -rf uploads")
            run("mkdir uploads")
            run("code/bin/paster setup-app release.ini")

    def crontab(self):
        return ["curl -s http://ututi.com/news/daily?date=`date -u +%Y-%m-%d` > /dev/null",
                "curl -s http://ututi.com/news/hourly -F date=`date -u +%Y-%m-%d` -F hour=`date -u +%H` > /dev/null"]

    @run_as_user
    def import_backup(self):
        self.clear_database()
        # $PG_PATH/bin/pg_restore -d release -h $PWD/var/run < $1/dbdump || true
        # rsync -rt $1/files_dump/uploads/ uploads/

    @run_as_user
    def import_inital_backup(self, local_backup):
        run('mkdir -p %s' % '{backup_dir}/initial'.format(backup_dir=self.settings.backups_dir))
        put(local_backup, '{backup_dir}/initial/dbdump'.format(backup_dir=self.settings.backups_dir))
        self.stop()
        with settings(warn_only=True):
            self.clear_database()
            self.server.getService(self.database).import_dump('{backup_dir}/initial/dbdump'.format(backup_dir=self.settings.backups_dir))
        self.start()
        self.ensure_all_files_present()

    @run_as_user
    def migrate(self):
        with self.dir():
            run("code/bin/migrate release.ini")

    @run_as_sudo
    def start(self):
        run('supervisorctl start %s' % self.name)

    @run_as_sudo
    def stop(self):
        run('supervisorctl stop %s' % self.name)

    @run_as_sudo
    def restart(self):
        run('supervisorctl restart %s' % self.name)

    @run_as_sudo
    def setup(self, initial_release):
        self.server.ensure_user(self.user)
        self.create_site_dirs()

        self.upload_release(initial_release)
        self.build()

        self.ensure_instance_dirs()
        self.link_release()
        self.update_release_ini()
        self.reset_database()

        self.configure()
        # self.server.cron_setup(self.crontab) # XXX not implemented

    @run_as_sudo
    def release(self):
        release_dir = self.getNextReleaseIfReady()
        if release_dir:
            self.stop()
            self.link_release(release_dir)
            self.migrate()
            self.start()
        else:
            warn("Next release not ready yet")

    @run_as_user
    def getLastPackagedRelease(self):
        return run("find %s | sort | tail -1" % self.settings.package_dir).strip()

    build_db_port = 8862

    @run_as_user
    def build(self, rebuild=False):
        build_lock = os.path.join(self.settings.build_dir, 'build.lock')
        if exists(build_lock) and not rebuild:
            warn("Package is being built aborting!")
            return

        run("touch %s" % build_lock)
        try:
            package_file = self.getLastPackagedRelease()
            release_name = os.path.basename(package_file).replace('.tar.gz', '')
            release_dir = os.path.join(self.settings.build_dir, release_name)

            if exists(release_dir) and not rebuild:
                warn("Package has been built already run build:rebuild to rebuild it.")
                return

            if rebuild and exists(release_dir):
                run("rm -r %s" % release_dir)

            run("mkdir %s" % release_dir)
            run("tar -xvzf %s -C %s" % (package_file, self.settings.build_dir))

            with cd(release_dir):
                with prefix("export PGPORT=%s" % self.build_db_port):
                    try:
                        run('make BUILDOUT_OPTIONS="'
                            "buildout:eggs-directory='{buildout_eggs}' "
                            "buildout:download-cache='{buildout_cache}' "
                            "buildout:extends-cache='{buildout_extends}' "
                            '" bin/paster compile-translations bin/test'.format(
                                buildout_eggs=self.settings.buildout_eggs,
                                buildout_cache=self.settings.buildout_cache,
                                buildout_extends=self.settings.buildout_extends))
                        run("make start_database")
                        run("make test")
                    finally:
                        run("make stop_database")
                    run("rm -rf instance")
                    run("touch READY")
        finally:
            run("rm %s" % build_lock)

    @run_as_sudo
    def update_postfix_transport(self):
        # XXX kill all lines that start with group hostname in /etc/postfix/transport
        append('/etc/postfix/transport', '{groups_host_name}  {name}_mailer:'.format(
                groups_host_name=self.settings.groups_host_name,
                name=self.name))
        run('postmap /etc/postfix/transport')

    @run_as_sudo
    def update_postfix_main_cf(self):
        """ # /etc/postfix/main.cf
        mydestination = ututi.com, avilys, localhost.localdomain, localhost
        virtual_alias_domains = korys.org, ututi.lt, ututi.pl
        relay_domains = lists.ututi.lt groups.ututi.lt groups.ututi.pl nous.lt groups.ututi.com
        """
        with settings(warn_only=True):
            relay_domains = run('grep "^relay_domains" /etc/postfix/main.cf', shell=False)
        if relay_domains:
            key, value = relay_domains.strip().split('=')
        else:
            key, value = 'relay_domains', ''
        domains = [domain.strip() for domain in value.split(' ')]
        if self.settings.groups_host_name not in domains:
            domains.append(self.settings.groups_host_name)
        new_relay_domains = '{key} = {value}'.format(
            key=key.strip(),
            value=' '.join(domains).strip())
        if relay_domains:
            sed('/etc/postfix/main.cf', relay_domains, new_relay_domains)
        else:
            append('/etc/postfix/main.cf', new_relay_domains)

        append('/etc/postfix/main.cf', 'transport_maps = hash:/etc/postfix/transport')


    @run_as_sudo
    def update_postfix_master_cf(self):
        master_cf_orig = StringIO()
        get('/etc/postfix/master.cf', master_cf_orig)
        master_cf_orig.seek(0)
        lines = [l.rstrip() for l in master_cf_orig.readlines()]
        for n, l in enumerate(lines):
            if l.startswith('{name}_mailer'.format(name=self.settings.name)):
                found = True
                break
        else:
            found = False

        if found:
            lines = lines[0:n] + lines[n+3:]
        lines.extend([
                '{name}_mailer  unix  -       n       n       -       -       pipe'.format(name=self.settings.name),
                '  flags=FR user={user} argv={instance_code_dir}/bin/mailpost http://{host_name}/got_mail {upload_dir}'.format(
                    user=self.user,
                    instance_code_dir=self.settings.instance_code_dir,
                    host_name=self.settings.host_name,
                    upload_dir=self.settings.upload_dir),
                '  ${nexthop} ${user}',
            ])
        master_cf_new = StringIO('\n'.join(lines) + '\n')
        put(master_cf_new, '/etc/postfix/master.cf', mode=0o644)

    @run_as_sudo
    def configure_postfix(self):
        self.update_postfix_master_cf()
        self.update_postfix_main_cf()
        self.update_postfix_transport()
        run('postfix reload')

    @run_as_user
    def ensure_all_files_present(self):
        with settings(forward_agent=True):
            run(' '.join([os.path.join(self.settings.instance_code_dir, 'bin/py'),
                          os.path.join(self.settings.instance_code_dir, 'scripts/ensure_all_files_present.py'),
                          os.path.join(self.settings.instance_dir, 'release.ini'),
                          'ututi@ututi.com',
                          '/srv/ututi.com/instance/uploads',
                          self.settings.upload_dir]))
