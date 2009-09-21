import pkg_resources

def upgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '009_add_subscribed_column_for_group_members.sql')
    connection.execute(statements)


def downgrade(engine):
    connection = engine.connect()
    statements = pkg_resources.resource_string('ututi.migration', '009_add_subscribed_column_for_group_members_downgrade.sql')
    connection.execute(statements)
