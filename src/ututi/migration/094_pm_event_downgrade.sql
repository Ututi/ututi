alter table events alter column object_id set not null;
alter table events drop column private_message_id;
