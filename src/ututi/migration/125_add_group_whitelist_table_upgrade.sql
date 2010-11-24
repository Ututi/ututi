create table group_whitelist (
       id bigserial not null,
       group_id int8 default null references groups(id) on delete cascade,
       email varchar(320) not null,
       primary key (id));
