CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'mailinglist_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;
