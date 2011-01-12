drop FUNCTION get_group_forum_post_event_parent(forum_posts);

CREATE OR REPLACE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        INSERT INTO events (object_id, author_id, event_type, post_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
