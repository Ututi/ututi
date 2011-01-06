alter table events add column parent_id int8 default null references events(id) on delete cascade;
