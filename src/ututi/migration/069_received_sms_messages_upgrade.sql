CREATE TABLE received_sms_messages (
       id bigserial not null,
       sender_id int8 references users(id),
       group_id int8 references groups(id),
       sender_phone_number varchar(20) default null,
       message_type varchar(30),
       message_text text,
       received timestamp not null default (now() at time zone 'UTC'),
       success boolean default null,
       result text,
       request_url text,
       test boolean default false,
       primary key (id));
