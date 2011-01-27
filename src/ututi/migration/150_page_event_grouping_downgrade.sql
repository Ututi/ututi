CREATE OR REPLACE FUNCTION page_modified_trigger() RETURNS trigger AS $$
    DECLARE
      version_count int8 := NULL;
      sid int8 := NULL;
    BEGIN
      SELECT count(*) INTO version_count FROM page_versions WHERE page_id = NEW.page_id;
      IF version_count > 1 THEN
        SELECT subject_id INTO sid FROM subject_pages WHERE page_id = NEW.page_id;
        IF FOUND THEN
          INSERT INTO events (object_id, author_id, event_type, page_id)
                 VALUES (sid, cast(current_setting('ututi.active_user') as int8), 'page_modified', NEW.page_id);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
