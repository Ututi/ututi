alter table books add column city_id int8 default null references cities(id) on delete restrict;;
alter table books drop column release_date;;
alter table books drop column publisher;;
alter table books drop column pages_number;;
alter table books drop column location;;

