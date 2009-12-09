DROP TRIGGER file_event_trigger ON files;

CREATE OR REPLACE FUNCTION file_event_trigger() RETURNS trigger AS $$
    DECLARE parent_type varchar(20) := NULL;
    BEGIN
      IF NOT NEW.parent_id is NULL THEN
        SELECT content_type INTO parent_type FROM content_items WHERE id = NEW.parent_id;
        IF parent_type in ('subject', 'group') THEN
          INSERT INTO events (object_id, author_id, event_type, file_id)
                 VALUES (NEW.parent_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.id);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER file_event_trigger AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE file_event_trigger();
