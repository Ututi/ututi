/* Create first user=admin and password=asdasd */

create table users (id bigserial not null, fullname varchar(100), password char(36), primary key (id));;

insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');;

/* Storing the emails of the users. */
create table emails (id int8 not null references users(id),
       email varchar(320),
       confirmed boolean default FALSE,
       confirmation_key char(32) default '',
       primary key (email));;


CREATE FUNCTION lowercase_email() RETURNS trigger AS $lowercase_email$
    BEGIN
        NEW.email := lower(NEW.email);
        RETURN NEW;
    END
$lowercase_email$ LANGUAGE plpgsql;;


CREATE TRIGGER lowercase_email BEFORE INSERT OR UPDATE ON emails
    FOR EACH ROW EXECUTE PROCEDURE lowercase_email();;


CREATE OR REPLACE FUNCTION get_users_by_email(email_address varchar) returns users AS $get_user_by_email$
        select users.* from users join emails on users.id = emails.id
                 where emails.email=lower($1)
$get_user_by_email$ LANGUAGE sql;;

insert into emails (id, email, confirmed) values (1, 'admin@ututi.lt', true);;

/* A table for universities and faculties (maybe later even tags) */
create table locationtags (id bigserial not null,
       parent int8 references locationtags(id) default null,
       title varchar(250),
       title_short varchar(50),
       description text,
       primary key (id));;

insert into locationtags (title, title_short, description)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.');;
insert into locationtags (title, title_short, description, parent)
       values ('Ekonomikos fakultetas', 'ef', '', 1);;

/* A table for groups */
create table groups (id varchar(250) not null,
       title varchar(250) not null,
       location int8 references locationtags(id) default null,
       year date not null,
       description text,
       primary key (id));;

insert into groups (id, title, description, year, location)
       select 'moderators', 'Moderatoriai', 'U2ti moderatoriai.', date('2009-1-1'), locationtags.id
              from locationtags where locationtags.title_short='vu' and locationtags.parent is null;;

/* A table for subjects */
create table subjects (id bigserial not null,
       text_id varchar(50) default null,
       title varchar(500) not null,
       lecturer varchar(500) default null,
       location int8 references locationtags(id) default null,
       primary key (id));;
create unique index text_id on subjects(text_id);;

insert into subjects (text_id, title, lecturer)
       values ('mat_analize', 'Matematinė analizė', 'prof. E. Misevičius');;

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
       primary key (id));;

create index md5 on files (md5);;

/* A table for group mailing list emails */

create table group_mailing_list_messages (
       message_id varchar(320) not null,
       group_id varchar(250) references groups(id) not null,
       sender_email varchar(320),
       reply_to_message_id varchar(320) default null,
       reply_to_group_id varchar(250) references groups(id) default null,
       author_id int8 references users(id) not null,
       subject varchar(500),
       body text default '',
       created time default now(),
       foreign key (reply_to_message_id, reply_to_group_id) references group_mailing_list_messages,
       primary key (message_id, group_id));;

/* A table that tracks attachments for messages */

create table group_mailing_list_attachments (
       message_id varchar(320) not null,
       group_id varchar(250) not null,
       file_id int8 references files(id) not null,
       foreign key (message_id, group_id) references group_mailing_list_messages,
       primary key (message_id, group_id, file_id));;
