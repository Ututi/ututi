ALTER TABLE events DROP COLUMN sms_id;

DROP TRIGGER outgoing_group_sms_event_trigger ON outgoing_group_sms_messages;
DROP FUNCTION outgoing_group_sms_event_trigger();
