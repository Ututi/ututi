/* Create first user=admin and password=asdasd */

create table users (id bigserial not null, fullname varchar(100), password char(36), primary key (id));

insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');

/* Storing the emails of the users. */
create table emails (id int8 not null references users(id),
       email varchar(320),
       confirmed boolean default FALSE,
       confirmation_key char(32) default '',
       primary key (email));

insert into emails (id, email, confirmed) values (1, 'admin@ututi.lt', true);

/* A table for universities and faculties (maybe later even tags) */
create table locationtags (id bigserial not null,
       parent int8 references locationtags(id) default null,
       title varchar(250),
       title_short varchar(50),
       description text,
       primary key (id));

insert into locationtags (title, title_short, description)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.');
insert into locationtags (title, title_short, description, parent)
       values ('Ekonomikos fakultetas', 'ef', '', 1);

/* A table for groups */
create table groups (id varchar(250) not null,
       title varchar(250) not null,
       location int8 references locationtags(id) not null,
       year date not null,
       description text,
       primary key (id));

insert into groups (id, title, description, year, location)
       select 'moderators', 'Moderatoriai', 'U2ti moderatoriai.', date('2009-1-1'), locationtags.id
              from locationtags where locationtags.title_short='vu' and locationtags.parent is null;

/* A table for files */

create table files (id bigserial not null,
       md5 char(32) not null,
       mimetype varchar(255) default 'application/octet-stream',
       filesize int8,
       filename varchar(500),
       title varchar(500),
       description text default '',
       created time default now(),
       modified time default null,
       primary key (id));

create index md5 on files (md5);
