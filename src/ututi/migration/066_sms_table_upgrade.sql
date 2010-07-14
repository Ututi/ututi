CREATE TABLE sms (
       id bigserial not null,
       sender_uid int8 references users(id) on delete cascade not null,
       recipient_uid int8 references users(id) on delete cascade default null,
       recipient_number varchar(20),
       message_text text not null,
       created timestamp not null default (now() at time zone 'UTC'),
       processed timestamp default null,
       sent timestamp default null,
       status int default null,
       primary key (id));
