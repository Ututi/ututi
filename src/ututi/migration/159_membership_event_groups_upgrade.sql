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
      ELSIF evt.event_type = 'file_uploaded' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = 'file_uploaded'
             AND e.object_id = evt.object_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'member_joined' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = evt.event_type
             AND e.object_id = evt.object_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'member_left' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = evt.event_type
             AND e.object_id = evt.object_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      END IF;
      IF evt.event_type IN ('subject_modified', 'page_modified', 'file_uploaded', 'member_joined', 'member_left') AND NOT pid IS null THEN
        UPDATE events SET parent_id = evt.id WHERE id = pid or parent_id = pid;
      END IF;
    END;
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION member_group_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (OLD.group_id, OLD.user_id, 'member_left')
               RETURNING * INTO evt;
      ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (NEW.group_id, NEW.user_id, 'member_joined')
               RETURNING * INTO evt;
      END IF;
      EXECUTE event_set_group(evt);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events SET parent_id = null WHERE event_type in ('member_joined', 'member_left');
select event_set_group(e.*) FROM events e WHERE e.event_type in ('member_joined', 'member_left') ORDER BY e.created asc;
