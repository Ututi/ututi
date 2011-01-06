DROP INDEX events_parent_id_idx;
DROP INDEX events_created_idx;

DROP FUNCTION get_private_message_event_parent(private_messages);;

CREATE OR REPLACE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = NULL
  WHERE events.event_type = 'private_message_sent';
