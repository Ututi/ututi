def upgrade(engine, language):
    connection = engine.connect()
    duplicates = list(connection.execute("select parent_id, title from tags group by title, parent_id having count(title) > 1;"))

    for parent_id, title in duplicates:
        tags = list(connection.execute("select id from tags where title = '%s' and parent_id = %d order by id asc" % (title, parent_id)))

        #find the tag we are going to keep
        first_tag = tags[0][0]

        #delete the duplicates
        for (tag,) in tags[1:]:
            connection.execute("update content_items set location_id = %d where location_id = %d" % (first_tag, tag))
            connection.execute("update users set location_id = %d where location_id = %d" % (first_tag, tag))
            connection.execute("delete from tags where id = %d" % tag)

def downgrade(engine, language):
    #no downgrade available!
    pass
