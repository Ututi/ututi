alter table events add column recipient_id int8 default null references users(id);
