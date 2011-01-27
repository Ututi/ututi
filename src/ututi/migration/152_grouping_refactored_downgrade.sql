DROP FUNCTION add_event_r(event_id int8, evtype varchar);
CREATE FUNCTION add_event_r(event_id int8, evtype varchar) RETURNS int8 AS $$
    DECLARE
      evt int8 := NULL;
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype)
             RETURNING id INTO evt;
      RETURN evt;
    END
$$ LANGUAGE plpgsql;;

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

DROP FUNCTION event_set_group(evt events);

CREATE OR REPLACE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
      eid int8 := NULL;
      pid int8 := NULL;
      evt int8 := NULL;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          SELECT id INTO eid FROM events WHERE object_id = NEW.id AND event_type = 'subject_created';
          IF NOT FOUND THEN
              evt := add_event_r(NEW.id, cast('subject_created' as varchar));
          END IF;
      ELSE
         SELECT id INTO pid FROM events e WHERE e.event_type in ('subject_modified', 'subject_created')
             AND e.object_id = NEW.id
             AND e.author_id = cast(current_setting('ututi.active_user') as int8)
             AND now() AT time zone 'UTC' - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             ORDER BY e.created DESC
             LIMIT 1;
         evt := add_event_r(NEW.id, cast('subject_modified' as varchar));
         UPDATE events SET parent_id = evt WHERE id = pid or parent_id = pid;

      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
