create table teacher_groups (
       id bigserial not null,
       user_id int8 references users(id) not null,
       title varchar(500) not null,
       email varchar(320) not null,
       group_id int8 default null references groups(id) on delete cascade,
       primary key (id));;
