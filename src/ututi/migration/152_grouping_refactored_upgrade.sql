DROP FUNCTION add_event_r(event_id int8, evtype varchar);
CREATE OR REPLACE FUNCTION add_event_r(event_id int8, evtype varchar) RETURNS events AS $$
    DECLARE
      evt events;
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype)
             RETURNING * INTO evt;
      RETURN evt;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION event_set_group(evt events) RETURNS void as $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF evt.event_type = 'subject_modified' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type in ('subject_modified', 'subject_created')
             AND e.object_id = evt.object_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      END IF;
      IF evt.event_type = 'page_modified' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type in ('page_modified', 'page_created')
             AND e.object_id = evt.object_id
             AND e.page_id = evt.page_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      END IF;
      IF evt.event_type IN ('subject_modified', 'page_modified') THEN
        UPDATE events SET parent_id = evt.id WHERE id = pid or parent_id = pid;
      END IF;
    END;
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION page_modified_trigger() RETURNS trigger AS $$
    DECLARE
      version_count int8 := NULL;
      sid int8 := NULL;
      evt events;
      pid int8 := NULL;
    BEGIN
      SELECT count(*) INTO version_count FROM page_versions WHERE page_id = NEW.page_id;
      IF version_count > 1 THEN
        SELECT subject_id INTO sid FROM subject_pages WHERE page_id = NEW.page_id;
        IF FOUND THEN
          INSERT INTO events (object_id, author_id, event_type, page_id)
                 VALUES (sid, cast(current_setting('ututi.active_user') as int8), 'page_modified', NEW.page_id)
                 RETURNING * INTO evt;
          EXECUTE event_set_group(evt);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
      eid int8 := NULL;
      evt events;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          SELECT id INTO eid FROM events WHERE object_id = NEW.id AND event_type = 'subject_created';
          IF NOT FOUND THEN
              evt := add_event_r(NEW.id, cast('subject_created' as varchar));
          END IF;
      ELSE
         evt := add_event_r(NEW.id, cast('subject_modified' as varchar));
         EXECUTE event_set_group(evt);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
