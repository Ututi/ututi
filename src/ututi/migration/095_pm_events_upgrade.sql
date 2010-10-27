CREATE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER private_message_event_trigger AFTER INSERT ON private_messages
    FOR EACH ROW EXECUTE PROCEDURE private_message_event_trigger();;
