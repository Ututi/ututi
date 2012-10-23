import sys
import os
import re
import pkg_resources

from martian.scan import module_info_from_dotted_name

MIN_VERSION = 202


def sql_migrate(name):
    base_name = name.split('.')[-1]
    upgrade_file = "%s_upgrade.sql" % base_name
    downgrade_file = "%s_downgrade.sql" % base_name

    def upgrade(engine):
        connection = engine.connect()
        statements = pkg_resources.resource_string('ututi.migration', upgrade_file)
        connection.execute(statements)

    def downgrade(engine):
        connection = engine.connect()
        statements = pkg_resources.resource_string('ututi.migration', downgrade_file)
        connection.execute(statements)

    return upgrade, downgrade


class EvolutionScript(object):
    def __init__(self, version, title, upgrade, downgrade):
        self.version = version
        self.title = title
        self.upgrade = upgrade
        self.downgrade = downgrade


class GreatMigrator(object):

    min_version = MIN_VERSION

    def __init__(self, engine):
        self.engine = engine

    @property
    def evolution_scripts(self):
        script_module = \
            module_info_from_dotted_name("ututi.migration")

        directory = os.path.dirname(script_module.path)
        script_modules = []
        script_pattern = r"(\d{3})_(.*)"
        for entry in sorted(os.listdir(directory)):
            name, ext = os.path.splitext(entry)
            match = re.match(script_pattern, name)
            if ext == '.py' and match:
                dotted_name = script_module.dotted_name + '.' + name
                script_modules.append(module_info_from_dotted_name(dotted_name))

        scripts = []
        for script in sorted(script_modules, key=lambda s: s.name):
            match = re.match(script_pattern, script.name)
            if match:
                version, name = match.groups()
                scripts.append(EvolutionScript(int(version),
                                               name,
                                               script.getModule().upgrade,
                                               script.getModule().downgrade))
        return scripts

    def getCurrentVersion(self):
        connection = self.engine.connect()
        connection.execute("select * from db_versions")
        connection.close()

    @property
    def last_version(self):
        return self.evolution_scripts[-1].version

    @property
    def db_version(self):
        connection = self.engine.connect()
        versions = list(connection.execute("select * from db_versions"))
        if 0 < len(versions) < 2:
            return versions[0][0]
        else:
            raise ValueError(versions)
        connection.close()

    def initializeVersionning(self):
        connection = self.engine.connect()
        rs = connection.execute(
            "select * from pg_tables where tablename='db_versions'")
        versions = list(rs)
        if len(versions) == 0:
            connection.execute("create table db_versions (version int8 not null)")
            connection.execute("insert into db_versions (version) values (%d)" %
                               self.last_version)
        connection.close()

    def run_scripts(self, start, end):
        connection = self.engine.connect()
        tx = connection.begin()

        for script in self.evolution_scripts[start:end]:
            print "Running:", script.title
            script.upgrade(connection)

        print "Setting database version to:", end
        connection.execute("update db_versions set version=%d" % end)

        tx.commit()
        connection.close()

    def run_downgrade_scripts(self, start):
        connection = self.engine.connect()
        tx = connection.begin()

        down = start - 1

        script = self.evolution_scripts[start-1]
        print "Running:", script.title
        script.downgrade(connection)

        print "Setting database version to:", down
        connection.execute("update db_versions set version=%d" % down)

        tx.commit()
        connection.close()

    def upgrade_once(self):
        if self.db_version < self.min_version:
            self.run_scripts(self.db_version, self.db_version + 1)

    def upgrade_min(self):
        if self.min_version > self.db_version:
            self.run_scripts(self.db_version, self.min_version)

    def upgrade_max(self):
        if self.last_version > self.db_version:
            self.run_scripts(self.db_version, self.last_version)

    def downgrade(self):
        if self.db_version > 1:
            self.run_downgrade_scripts(self.db_version)

def main():
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'development.ini'
    action = sys.argv[2] if len(sys.argv) > 2 else 'upgrade'

    config_name = 'config:%s' % config_file

    from sqlalchemy import engine_from_config
    from paste.deploy.loadwsgi import ConfigLoader

    clo = ConfigLoader(config_file)

    # migrate supports passing url as an existing Engine instance (since 0.6.0)
    # usage: migrate -c path/to/config.ini COMMANDS
    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    engine = engine_from_config(dict(clo.parser.items('app:main')))

    # XXX Avoid circular import
    migrator = GreatMigrator(engine)

    if action == 'upgrade':
        migrator.upgrade_min()
    if action == 'upgrade_once':
        migrator.upgrade_once()
    if action == 'downgrade':
        migrator.downgrade()
