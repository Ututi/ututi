/* A table for files */

create table files (id bigserial not null,
       md5 char(32),
       folder varchar(255) default '' not null,
       mimetype varchar(255) default 'application/octet-stream',
       filesize int8,
       filename varchar(500),
       title varchar(500),
       description text default '',
       created timestamp default now(),
       modified timestamp default null,
       primary key (id));;

create index md5 on files (md5);;

/* Create first user=admin and password=asdasd */

create table users (
       id bigserial not null,
       fullname varchar(100),
       password char(36),
       logo_id int8 references files(id) default null,
       primary key (id));;

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
       parent_id int8 references locationtags(id) default null,
       title varchar(250),
       title_short varchar(50),
       description text,
       logo_id int8 references files(id) default null,
       primary key (id));;

insert into locationtags (title, title_short, description)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.');;
insert into locationtags (title, title_short, description, parent_id)
       values ('Ekonomikos fakultetas', 'ef', '', 1);;

/* A table for groups */
create table groups (id varchar(250) not null,
       title varchar(250) not null,
       location int8 references locationtags(id) default null,
       year date not null,
       description text,
       logo_id int8 references files(id) default null,
       primary key (id));;


/* An enumerator for membership types in groups */
create table group_membership_types (
       membership_type varchar(20) not null,
       primary key (membership_type));;


/* A table that tracks user membership in groups */
create table group_members (
       group_id varchar(250) references groups(id) not null,
       user_id int8 references users(id) not null,
       membership_type varchar(20) references group_membership_types(membership_type) not null,
       primary key (group_id, user_id));;


insert into groups (id, title, description, year, location)
       select 'moderators', 'Moderatoriai', 'U2ti moderatoriai.', date('2009-1-1'), locationtags.id
              from locationtags where locationtags.title_short='vu' and locationtags.parent_id is null;;

insert into group_membership_types (membership_type)
                      values ('administrator');;
insert into group_membership_types (membership_type)
                      values ('member');;

insert into group_members (group_id, user_id, membership_type)
                   values ('moderators', 1, 'administrator');;

/* A table for subjects */
create table subjects (id varchar(150) default null,
       title varchar(500) not null,
       lecturer varchar(500) default null,
       location_id int8 references locationtags(id) not null,
       primary key (id, location_id));;

insert into subjects (id, title, lecturer, location_id)
       select 'mat_analize', 'Matematinė analizė', 'prof. E. Misevičius', locationtags.id
              from locationtags where locationtags.title_short='vu' and locationtags.parent_id is null;;

/* A table that tracks subject files */

create table subject_files (
       subject_id varchar(150) not null,
       subject_location_id int8 not null,
       file_id int8 references files(id) not null,
       foreign key (subject_id, subject_location_id) references subjects,
       primary key (subject_id, file_id));;

/* A table for pages */

create table pages (id bigserial not null, primary key(id));;

create table page_versions(id bigserial not null,
       page_id int8 references pages(id) not null,
       created timestamp not null default now(),
       title varchar(255) not null default '',
       content text not null default '',
       user_id int8 references users(id) not null,
       primary key (id));;

/* A table linking pages and subjects */

create table subject_pages (
       subject_id varchar(150) not null,
       subject_location_id int8 not null,
       page_id int8 not null references pages(id),
       foreign key (subject_id, subject_location_id) references subjects,
       primary key (subject_id, subject_location_id, page_id));;

/* A table that tracks group files */

create table group_files (
       group_id varchar(250) references groups(id) not null,
       file_id int8 references files(id) not null,
       primary key (group_id, file_id));;

/* A table that tracks subjects watched by a group  */

create table group_watched_subjects (
       group_id varchar(250) references groups(id) not null,
       subject_id varchar(150) not null,
       subject_location_id int8 not null,
       foreign key (subject_id, subject_location_id) references subjects,
       primary key (group_id, subject_id, subject_location_id));;

/* A table linking pages and groups */

create table group_pages (
       group_id varchar(250) not null references groups(id),
       page_id int8 not null references pages(id),
       primary key (group_id, page_id));

/* A table for group mailing list emails */

create table group_mailing_list_messages (
       id bigserial not null unique,
       message_id varchar(320) not null,
       group_id varchar(250) references groups(id) not null,
       sender_email varchar(320),
       reply_to_message_id varchar(320) default null,
       reply_to_group_id varchar(250) references groups(id) default null,
       thread_message_id varchar(320) not null,
       thread_group_id varchar(250) references groups(id) not null,
       author_id int8 references users(id) not null,
       subject varchar(500) not null,
       original text not null,
       sent timestamp not null,
       created timestamp default now(),
       constraint reply_to
       foreign key (reply_to_message_id, reply_to_group_id) references group_mailing_list_messages(message_id, group_id),
       constraint thread
       foreign key (thread_message_id, thread_group_id) references group_mailing_list_messages(message_id, group_id),
       primary key (message_id, group_id));;


CREATE FUNCTION set_thread_id() RETURNS trigger AS $$
    DECLARE
        new_group_id varchar(320) := NULL;
        new_message_id varchar(250) := NULL;
    BEGIN
        IF NEW.reply_to_message_id is NULL THEN
          NEW.thread_message_id := NEW.message_id;
          NEW.thread_group_id := NEW.group_id;
        ELSE
          SELECT thread_message_id, thread_group_id INTO new_message_id, new_group_id
            FROM group_mailing_list_messages
            WHERE message_id = NEW.reply_to_message_id AND group_id = NEW.reply_to_group_id;
          NEW.thread_message_id := new_message_id;
          NEW.thread_group_id := new_group_id;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER lowercase_email BEFORE INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE set_thread_id();;


/* A table that tracks attachments for messages */

create table group_mailing_list_attachments (
       message_id varchar(320) not null,
       group_id varchar(250) not null,
       file_id int8 references files(id) not null,
       foreign key (message_id, group_id) references group_mailing_list_messages,
       primary key (message_id, group_id, file_id));;
