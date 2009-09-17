# Fix group ids that have slashes or + signs

def upgrade(engine):
    connection = engine.connect()

    connection.execute(r"ALTER TABLE files ADD COLUMN parent_id int8 DEFAULT NULL references content_items(id)")
    connection.execute(r"ALTER TABLE content_items DROP COLUMN parent_id")

    #subject files
    files = list(connection.execute(r"select subject_id, file_id from subject_files"))
    for file in files:
        connection.execute("update files set parent_id = %i where id = %i" % (file[0], file[1]))

    #group files
    files = list(connection.execute(r"select group_id, file_id from group_files"))
    for file in files:
        connection.execute("update files set parent_id = %i where id = %i" % (file[0], file[1]))

    #mailing list attachments
    files = list(connection.execute(r"select message_id, group_id, file_id from group_mailing_list_attachments"))
    for file in files:
        id = list(connection.execute(r"select id from group_mailing_list_messages where group_id = %i and message_id = '%s'" % (file[1], file[0])))
        connection.execute("update files set parent_id = %i where id = %i" % (id[0][0], file[2]))


def downgrade(engine):
    connection = engine.connect()
    connection.execute("SET ututi.active_user TO 1")
    connection.execute(r"ALTER TABLE content_items ADD COLUMN parent_id int8 DEFAULT NULL references content_items(id)")
    files = list(connection.execute("select f.id, f.parent_id, c.content_type from files f inner join content_items c on c.id = f.parent_id"))
    for file in files:
        if file[2] == 'subject':
            update_subject(connection, file[1], file[0])
        elif file[2] == 'group':
            update_group(connection, file[1], file[0])
        elif file[2] == 'mailing_list_message':
            update_message(connection, file[1], file[0])
        connection.execute("update files set parent_id = NULL where id = %i" % file[0])
    connection.execute("alter table files drop column parent_id")

def update_subject(connection, sid, fid):
    """Make sure the file is linked to the subject the old way."""
    found = list(connection.execute("select * from subject_files where file_id = %i" % fid))
    if len(found) != 0:
        connection.execute("update subject_files set subject_id = %i where file_id = %i" % (sid, fid))
    else:
        connection.execute("insert into subject_files (subject_id, file_id) values (%i, %i)" % (sid, fid))

def update_group(connection, gid, fid):
    """Make sure the file is linked to the subject the old way."""
    found = list(connection.execute("select * from group_files where file_id = %i" % fid))
    if len(found) != 0:
        connection.execute("update group_files set group_id = %i where file_id = %i" % (gid, fid))
    else:
        connection.execute("insert into group_files (group_id, file_id) values (%i, %i)" % (gid, fid))

def update_message(connection, mid, fid):
    """Make sure the file is linked to the subject the old way."""
    msg = list(connection.execute("select message_id, group_id from group_mailing_list_messages where id = %i" % mid))
    if len(msg) == 1:
        found = list(connection.execute("select * from group_mailing_list_attachments where file_id = %i" % fid))
        if len(found) != 0:
            connection.execute("update group_mailing_list_attachments set message_id = '%s', group_id = %i where file_id = %i" % (msg[0][0], msg[0][1], fid))
        else:
            connection.execute("insert into group_mailing_list_attachments (message_id, group_id, file_id) values ('%s', %i, %i)" % (msg[0][0], msg[0][1], fid))
