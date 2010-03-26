import pkg_resources

def my_sql_migrate(name):
    base_name = name.split('.')[-1]
    upgrade_file = "%s_upgrade.sql" % base_name
    downgrade_file = "%s_downgrade.sql" % base_name

    def upgrade(engine, lang):
        if lang != 'lt':
            return
        connection = engine.connect()
        statements = pkg_resources.resource_string('ututi.migration', upgrade_file)
        for statement in statements.splitlines():
            stmt = statement.strip()
            if stmt:
                tx = connection.begin()
                connection.execute("alter table files disable trigger all;")
                connection.execute("alter table content_items disable trigger all;")
                connection.execute(stmt)
                connection.execute("alter table files enable trigger all;")
                connection.execute("alter table content_items enable trigger all;")
                tx.commit()

    def downgrade(engine, lang):
        connection = engine.connect()
        statements = pkg_resources.resource_string('ututi.migration', downgrade_file)
        connection.execute(statements)

    return upgrade, downgrade

upgrade, downgrade = my_sql_migrate(__name__)
