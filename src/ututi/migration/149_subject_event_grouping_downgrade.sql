DROP FUNCTION add_event_r(event_id int8, evtype varchar);

CREATE OR REPLACE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
      eid int8 := NULL;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          SELECT id INTO eid FROM events WHERE object_id = NEW.id AND event_type = 'subject_created';
          IF NOT FOUND THEN
              EXECUTE add_event(NEW.id, cast('subject_created' as varchar));
          END IF;
      ELSE
         EXECUTE add_event(NEW.id, cast('subject_modified' as varchar));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
