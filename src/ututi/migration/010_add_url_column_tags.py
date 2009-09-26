import pkg_resources

def upgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '010_add_url_column_tags.sql')
    connection.execute(statements)


def downgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '010_add_url_column_tags_downgrade.sql')
    connection.execute(statements)
