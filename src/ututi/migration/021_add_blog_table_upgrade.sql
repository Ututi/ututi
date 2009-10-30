create table blog (
       id bigserial not null,
       title varchar(50) not null default '',
       content text not null default '',
       url varchar(200) default null,
       primary key (id));
