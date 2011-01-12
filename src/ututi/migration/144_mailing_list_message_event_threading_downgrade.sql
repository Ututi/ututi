DROP FUNCTION get_group_mailing_list_message_event_parent(group_mailing_list_messages);;

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = NULL
  WHERE events.event_type = 'mailinglist_post_created';
