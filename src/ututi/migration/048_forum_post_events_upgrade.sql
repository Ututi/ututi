ALTER TABLE events ADD COLUMN post_id INT8 REFERENCES forum_posts(id) ON DELETE cascade DEFAULT NULL;

UPDATE events SET event_type = 'mailinglist_post_created' WHERE event_type = 'forum_post_created';


CREATE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
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

CREATE TRIGGER group_forum_message_event_trigger AFTER INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE group_forum_message_event_trigger();;
