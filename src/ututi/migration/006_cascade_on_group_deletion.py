import pkg_resources

def upgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '006_cascade_on_group_deletion.sql')
    connection.execute(statements)


def downgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '006_cascade_on_group_deletion_downgrade.sql')
    connection.execute(statements)
