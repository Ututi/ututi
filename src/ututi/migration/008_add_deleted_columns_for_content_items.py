import pkg_resources

def upgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '008_add_deleted_columns_for_content_items.sql')
    connection.execute(statements)


def downgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '008_add_deleted_columns_for_content_items_downgrade.sql')
    connection.execute(statements)
