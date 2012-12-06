CREATE SEQUENCE outgoing_group_sms_messages_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE received_sms_messages_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE sms_outbox_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE coupon_usage (
	coupon_id character varying(20) NOT NULL,
	group_id bigint,
	user_id bigint NOT NULL
);

CREATE TABLE outgoing_group_sms_messages (
	id bigint DEFAULT nextval('outgoing_group_sms_messages_id_seq'::regclass) NOT NULL,
	created timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
	sender_id bigint NOT NULL,
	group_id bigint NOT NULL,
	message_text text NOT NULL
);

CREATE TABLE received_sms_messages (
	id bigint DEFAULT nextval('received_sms_messages_id_seq'::regclass) NOT NULL,
	sender_id bigint,
	group_id bigint,
	sender_phone_number character varying(20) DEFAULT NULL::character varying,
	message_type character varying(30),
	message_text text,
	received timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
	success boolean,
	"result" text,
	request_url text,
	test boolean DEFAULT false
);

CREATE TABLE sms_outbox (
	id bigint DEFAULT nextval('sms_outbox_id_seq'::regclass) NOT NULL,
	sender_uid bigint NOT NULL,
	recipient_uid bigint,
	recipient_number character varying(20),
	message_text text NOT NULL,
	created timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
	processed timestamp without time zone,
	outgoing_group_message_id bigint,
	delivered timestamp without time zone,
	sending_status integer,
	delivery_status integer
);

ALTER TABLE events
	ADD COLUMN sms_id bigint;

CREATE OR REPLACE FUNCTION outgoing_group_sms_event_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, sms_id)
             VALUES (NEW.group_id, NEW.sender_id, 'sms_message_sent', NEW.id);
      RETURN NEW;
    END
$$;


ALTER TABLE coupon_usage
	ADD CONSTRAINT coupon_usage_pkey PRIMARY KEY (coupon_id, user_id);

ALTER TABLE outgoing_group_sms_messages
	ADD CONSTRAINT outgoing_group_sms_messages_pkey PRIMARY KEY (id);

ALTER TABLE received_sms_messages
	ADD CONSTRAINT received_sms_messages_pkey PRIMARY KEY (id);

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_pkey PRIMARY KEY (id);

ALTER TABLE events
	ADD CONSTRAINT events_sms_id_fkey FOREIGN KEY (sms_id) REFERENCES outgoing_group_sms_messages(id) ON DELETE CASCADE;

ALTER TABLE coupon_usage
	ADD CONSTRAINT coupon_usage_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES group_coupons(id);

ALTER TABLE coupon_usage
	ADD CONSTRAINT coupon_usage_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;

ALTER TABLE coupon_usage
	ADD CONSTRAINT coupon_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE outgoing_group_sms_messages
	ADD CONSTRAINT outgoing_group_sms_messages_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;

ALTER TABLE outgoing_group_sms_messages
	ADD CONSTRAINT outgoing_group_sms_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE received_sms_messages
	ADD CONSTRAINT received_sms_messages_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;

ALTER TABLE received_sms_messages
	ADD CONSTRAINT received_sms_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_outgoing_group_message_id_fkey FOREIGN KEY (outgoing_group_message_id) REFERENCES outgoing_group_sms_messages(id) ON DELETE CASCADE;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_recipient_uid_fkey FOREIGN KEY (recipient_uid) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_sender_uid_fkey FOREIGN KEY (sender_uid) REFERENCES users(id) ON DELETE CASCADE;

CREATE TRIGGER outgoing_group_sms_event_trigger
	AFTER INSERT ON outgoing_group_sms_messages
	FOR EACH ROW
	EXECUTE PROCEDURE outgoing_group_sms_event_trigger();
