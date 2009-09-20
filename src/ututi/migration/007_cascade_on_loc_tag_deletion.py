import pkg_resources

def upgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '007_cascade_on_loc_tag_deletion.sql')
    connection.execute(statements)


def downgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '007_cascade_on_loc_tag_deletion_downgrade.sql')
    connection.execute(statements)
