alter table users add column location_id int8 default null references tags(id) on delete set null;;
