DROP TRIGGER file_event_trigger ON files;
DROP FUNCTION file_event_trigger();

CREATE FUNCTION subject_file_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, file_id)
             VALUES (NEW.subject_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.file_id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;


CREATE TRIGGER subject_file_event_trigger AFTER INSERT OR UPDATE ON subject_files
    FOR EACH ROW EXECUTE PROCEDURE subject_file_event_trigger();


CREATE FUNCTION group_file_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, file_id)
             VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.file_id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER group_file_event_trigger AFTER INSERT OR UPDATE ON group_files
    FOR EACH ROW EXECUTE PROCEDURE group_file_event_trigger();
