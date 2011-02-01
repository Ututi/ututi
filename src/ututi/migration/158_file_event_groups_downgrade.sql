CREATE OR REPLACE FUNCTION file_event_trigger() RETURNS trigger AS $$
    DECLARE parent_type varchar(20) := NULL;
    BEGIN
      IF NOT NEW.parent_id is NULL THEN
        IF TG_OP = 'UPDATE' THEN
          IF OLD.parent_id = NEW.parent_id THEN
            RETURN NEW;
          END IF;
        END IF;
        SELECT content_type INTO parent_type FROM content_items WHERE id = NEW.parent_id;
        IF parent_type in ('subject', 'group') THEN
          INSERT INTO events (object_id, author_id, event_type, file_id)
                 VALUES (NEW.parent_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.id);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION event_set_group(evt events) RETURNS void as $$
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
      ELSIF evt.event_type = 'page_modified' THEN
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
      IF evt.event_type IN ('subject_modified', 'page_modified') AND NOT pid IS null THEN
        UPDATE events SET parent_id = evt.id WHERE id = pid or parent_id = pid;
      END IF;
    END;
$$ LANGUAGE plpgsql;;
