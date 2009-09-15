# Fix group ids that have slashes or + signs

def update_subject_events(connection, id):
    """For the subject specified, leave only one creation event, converting others to modification events."""
    firstevent = list(connection.execute(r"select id from events where event_type = 'subject_created' and object_id = %i order by created desc limit 1" % id))
    connection.execute(r"update events set event_type = 'subject_modified' where  object_id = %i and event_type = 'subject_created' and id != %i" % (int(id), int(firstevent[0][0])))

def upgrade(engine):
    connection = engine.connect()
    connection.execute(r"""
CREATE OR REPLACE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          EXECUTE add_event(NEW.id, cast('subject_created' as varchar));
      ELSE
         EXECUTE add_event(NEW.id, cast('subject_modified' as varchar));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER subject_event_trigger ON subjects;

CREATE TRIGGER subject_event_trigger BEFORE INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE subject_event_trigger();

    """)

    #find occasions where the same subject has several creation events
    repeats = list(connection.execute(r"select object_id, count(id) from events where event_type = 'subject_created' group by object_id"))
    for repeat in repeats:
        if repeat[1] > 1:
            update_subject_events(connection, repeat[0])

def downgrade(engine):
    connection = engine.connect()
    connection.execute(r"""
CREATE OR REPLACE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    BEGIN
      EXECUTE add_event(NEW.id, cast('subject_created' as varchar));
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER subject_event_trigger ON subjects;

CREATE TRIGGER subject_event_trigger AFTER INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE subject_event_trigger();
    """)
