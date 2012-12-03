def upgrade(engine):
    connection = engine.connect()
    connection.execute("ALTER TABLE emails ADD COLUMN main boolean DEFAULT true;")

    users_with_2_emails = list(connection.execute("select id from users where (select count(*) from emails where emails.id = users.id) > 1;"))

    for user_id in users_with_2_emails:
        user_emails = list(connection.execute("select email from emails where id = %d" % int(user_id[0])))
        for email in user_emails[1:]:
            connection.execute("update emails set main = false where id = %d and email = '%s';" % (int(user_id[0]), email[0]))


def downgrade(engine):
    connection = engine.connect()
    connection.execute("ALTER TABLE emails DROP COLUMN main;")
