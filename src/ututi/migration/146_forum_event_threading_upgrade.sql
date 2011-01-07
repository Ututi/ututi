CREATE OR REPLACE FUNCTION get_group_forum_post_event_parent(forum_posts) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id = obj.id THEN
            RETURN NULL; /* This post is root of the thread. */
        END IF;
        SELECT INTO id evt.id FROM events evt INNER JOIN forum_posts msg
               ON msg.id = evt.post_id
               WHERE msg.id = obj.thread_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        pid := get_group_forum_post_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, post_id, parent_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id, pid);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_group_forum_post_event_parent(msg.*)
      FROM forum_posts msg
      WHERE msg.id = events.post_id)
  WHERE events.event_type = 'forum_post_created';
