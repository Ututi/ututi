CREATE OR REPLACE FUNCTION group_forum_message_event_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      evt events;
      pid int8 := NULL;
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        pid := get_group_forum_post_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, post_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id)
               RETURNING * INTO evt;
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
      END IF;
      RETURN NEW;
    END
$$;

