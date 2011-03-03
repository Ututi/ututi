CREATE TABLE user_confirmations (
       created timestamp not null default (now() at time zone 'UTC'),
       email varchar(320) default null,
       location_id int8 not null references tags(id) on delete cascade,
       hash varchar(32) not null unique,
       primary key (hash),
       unique(location_id, email));;
