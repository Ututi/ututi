ALTER TABLE users
	ADD COLUMN phone_confirmed boolean DEFAULT false,
	ADD COLUMN phone_confirmation_key character(32) DEFAULT ''::bpchar,
	ADD COLUMN sms_messages_remaining bigint DEFAULT 30;
