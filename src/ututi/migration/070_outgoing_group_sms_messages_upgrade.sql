CREATE TABLE outgoing_group_sms_messages (
       id bigserial not null,
       created timestamp not null default (now() at time zone 'UTC'),
       sender_id int8 not null references users(id),
       group_id int8 not null references groups(id),
       message_text text not null,
       primary key (id));

ALTER TABLE sms ADD COLUMN outgoing_group_message_id int8 references outgoing_group_sms_messages(id);
