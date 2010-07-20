ALTER TABLE events ADD COLUMN sms_id int8 references outgoing_group_sms_messages(id) on delete cascade default null;

CREATE FUNCTION outgoing_group_sms_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, sms_id)
             VALUES (NEW.group_id, NEW.sender_id, 'sms_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER outgoing_group_sms_event_trigger AFTER INSERT ON outgoing_group_sms_messages
    FOR EACH ROW EXECUTE PROCEDURE outgoing_group_sms_event_trigger();;
