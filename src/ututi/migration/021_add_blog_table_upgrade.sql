create table blog (
       id bigserial not null,
       title varchar(50) not null default '',
       content text not null default '',
       url varchar(200) default null,
       created date not null default (now() at time zone 'UTC'),
       primary key (id));
