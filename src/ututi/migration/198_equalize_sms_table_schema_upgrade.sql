CREATE SEQUENCE sms_outbox_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

SELECT setval('sms_outbox_id_seq', (SELECT COALESCE(MAX(id), 0) + 1 FROM sms_outbox), false);

ALTER TABLE sms_outbox
	ALTER COLUMN id SET DEFAULT nextval('sms_outbox_id_seq'::regclass);

DROP SEQUENCE sms_id_seq;
