create table admin_users(
       id bigserial not null,
       email varchar(320),
       fullname varchar(100),
       password char(36),
       last_seen timestamp not null default (now() at time zone 'UTC'));;

/* Create first user=admin and password=asdasd */
insert into admin_users (email, fullname, password) values ('admin@ututi.lt', 'Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');;
