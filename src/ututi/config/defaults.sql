/* Create first user=admin and password=asdasd */

create table users (id bigserial not null, fullname varchar(100), password char(36), primary key (id));

insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');

/* Storing the emails of the users. */
create table emails (id int8 not null references users(id),
       email varchar(320),
       confirmed boolean default FALSE,
       confirmation_key char(32) default '',
       primary key (email));

insert into emails (id, email) values (1, 'admin@ututi.lt');

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

/* A table for files */

create table files (id bigserial not null,
       md5 char(32) not null,
       mimetype varchar(255),
       filesize int8,
       name varchar(500),
       title varchar(500),
       description text,
       created time,
       modified time,
       primary key (id));

create unique index md5 on files (md5);
