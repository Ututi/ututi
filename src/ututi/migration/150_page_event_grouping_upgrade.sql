CREATE OR REPLACE FUNCTION page_modified_trigger() RETURNS trigger AS $$
    DECLARE
      version_count int8 := NULL;
      sid int8 := NULL;
      evt int8 := NULL;
      pid int8 := NULL;
    BEGIN
      SELECT count(*) INTO version_count FROM page_versions WHERE page_id = NEW.page_id;
      IF version_count > 1 THEN
        SELECT subject_id INTO sid FROM subject_pages WHERE page_id = NEW.page_id;
        IF FOUND THEN
         SELECT id INTO pid FROM events e WHERE e.event_type in ('page_modified', 'page_created')
             AND e.object_id = sid
             AND e.page_id = NEW.page_id
             AND e.author_id = cast(current_setting('ututi.active_user') as int8)
             AND now() AT time zone 'UTC' - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             ORDER BY e.created DESC
             LIMIT 1;

          INSERT INTO events (object_id, author_id, event_type, page_id)
                 VALUES (sid, cast(current_setting('ututi.active_user') as int8), 'page_modified', NEW.page_id)
                 RETURNING id INTO evt;
          UPDATE events SET parent_id = evt WHERE id = pid or parent_id = pid;
        END IF;
      END IF;
      RETURN NEW;
   END
$$ LANGUAGE plpgsql;;

