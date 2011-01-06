CREATE OR REPLACE FUNCTION get_private_message_event_parent(private_messages) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id IS NULL THEN
            RETURN null;
        END IF;
        SELECT INTO id evt.id FROM events evt WHERE evt.private_message_id = obj.thread_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      pid := get_private_message_event_parent(NEW);
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id, parent_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id, pid);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_private_message_event_parent(pm.*)
      FROM private_messages pm
      WHERE pm.id = events.private_message_id)
  WHERE events.event_type = 'private_message_sent';
