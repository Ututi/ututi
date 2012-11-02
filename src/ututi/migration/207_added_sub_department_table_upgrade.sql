create table sub_departments (
       id bigserial not null,
       location_id int8 not null references tags(id) on delete cascade,
       slug varchar(150) default null,
       title varchar(500) not null,
       description text default null,
       unique(location_id, slug),
       primary key (id));;
