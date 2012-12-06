DROP FUNCTION outgoing_group_sms_event_trigger() CASCADE;

ALTER TABLE events
	DROP CONSTRAINT events_sms_id_fkey;

DROP TABLE coupon_usage;

DROP TABLE sms_outbox;

DROP TABLE outgoing_group_sms_messages;

DROP TABLE received_sms_messages;

ALTER TABLE events
	DROP COLUMN sms_id;
