create table blog (
       id bigserial not null,
       content text not null default '',
       created date not null default (now() at time zone 'UTC'),
       primary key (id));
