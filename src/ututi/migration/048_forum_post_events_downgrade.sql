ALTER TABLE events DROP COLUMN post_id;

UPDATE events SET event_type = 'forum_post_created' WHERE event_type = 'mailinglist_post_created';

DROP TRIGGER group_forum_message_event_trigger ON forum_posts;

DROP FUNCTION group_forum_message_event_trigger();

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, message_id)
             VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'forum_post_created', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;
