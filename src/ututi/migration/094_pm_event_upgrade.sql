alter table events add column private_message_id int8 references private_messages(id) on delete cascade default null;
