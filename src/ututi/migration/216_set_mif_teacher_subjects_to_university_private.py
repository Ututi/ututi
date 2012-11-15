def upgrade(engine):
    connection = engine.connect()
    mif_location, vu_location = list(connection.execute("select id, parent_id from tags"
                                                        " where title_short = 'mif' order by id asc;"))[0]
    mif_subject_ids = map(lambda r: r[0],
                          list(connection.execute("select subjects.id"
                                                  " from subjects, teacher_taught_subjects, content_items"
                                                  " where subjects.id = content_items.id"
                                                  " and teacher_taught_subjects.subject_id = subjects.id"
                                                  " and content_items.location_id = %d;" % mif_location)))
    connection.execute("alter table subjects disable trigger subject_event_trigger;")  # do not attempt to generate events for these changes.
    connection.execute("update subjects set visibility = 'university_members'"
                       " where id in (%s) and visibility = 'everyone';"
                       % (', '.join(map(str, mif_subject_ids)),))
    connection.execute("alter table subjects enable trigger subject_event_trigger;")

    # XXX Remove subjects for users who can't follow them anymore
    vu_locations = map(lambda r: r[0],
                       list(connection.execute("select id from tags where parent_id = %s" % vu_location))) + [vu_location]
    external_watchers = map(lambda r: r[0],
                            list(connection.execute("select user_id from user_monitored_subjects, users"
                                                    " where user_monitored_subjects.user_id = users.id"
                                                    " and user_monitored_subjects.subject_id in (%s)"
                                                    " and users.location_id not in (%s);"
                                                    % (', '.join(map(str, mif_subject_ids)),
                                                       ', '.join(map(str, vu_locations))))))
    connection.execute("delete from user_monitored_subjects where user_id in (%s) and subject_id in (%s);"
                       % (', '.join(map(str, external_watchers)), ', '.join(map(str, mif_subject_ids))))


def downgrade(engine):
    pass
