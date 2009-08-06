/* Language - specific configuration for full text search */
CREATE TEXT SEARCH DICTIONARY lithuanian (
    TEMPLATE = ispell,
    DictFile = system_lt_lt,
    AffFile = system_lt_lt
);;

CREATE TEXT SEARCH CONFIGURATION public.lt ( COPY = pg_catalog.english );
ALTER TEXT SEARCH CONFIGURATION lt
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH lithuanian;;

/* A generic table for Ututi objects */
create table content_items (id bigserial not null,
       parent_id int8 default null references content_items(id),
       content_type varchar(20) not null default '',
       primary key (id));;

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
       last_seen timestamp not null default now(),
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

/* A table for tags (location and simple tags) */
create table tags (id bigserial not null,
       parent_id int8 references tags(id) default null,
       title varchar(250) not null,
       title_short varchar(50) default null,
       description text default null,
       logo_id int8 references files(id) default null,
       tag_type varchar(10) default null,
       primary key (id));;

insert into tags (title, title_short, description, tag_type)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.', 'location');;
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('Ekonomikos fakultetas', 'ef', '', 1, 'location');;

/* A table for groups */
create table groups (
       id int8 references content_items(id),
       group_id varchar(250) not null unique,
       title varchar(250) not null,
       location_id int8 references tags(id) default null,
       year date not null,
       description text,
       show_page bool default true,
       page text not null default '',
       logo_id int8 references files(id) default null,
       primary key (id));;

/* An enumerator for membership types in groups */
create table group_membership_types (
       membership_type varchar(20) not null,
       primary key (membership_type));;


/* A table that tracks user membership in groups */
create table group_members (
       group_id int8 references groups(id) not null,
       user_id int8 references users(id) not null,
       membership_type varchar(20) references group_membership_types(membership_type) not null,
       primary key (group_id, user_id));;


insert into group_membership_types (membership_type)
                      values ('administrator');;
insert into group_membership_types (membership_type)
                      values ('member');;

/* A table for subjects */
create table subjects (id int8 not null references content_items(id),
       subject_id varchar(150) default null,
       title varchar(500) not null,
       lecturer varchar(500) default null,
       location_id int8 references tags(id) not null,
       primary key (id));;

create unique index subject_identifier on subjects (subject_id, location_id);


/* A table that tracks subject files */

create table subject_files (
       subject_id int8 not null references subjects(id),
       file_id int8 references files(id) on delete cascade not null,
       primary key (subject_id, file_id));;

/* A table that tracks subjects watched and ignored by a user */

create table user_monitored_subjects (
       user_id int8 references users(id) not null,
       subject_id int8 not null references subjects(id),
       ignored bool default false,
       primary key (user_id, subject_id));;

/* A table for pages */

create table pages (
       id int8 not null references content_items(id),
       location_id int8 references tags(id) default null,
       primary key(id));;

create table page_versions(id bigserial not null,
       page_id int8 references pages(id) not null,
       created timestamp not null default now(),
       title varchar(255) not null default '',
       content text not null default '',
       user_id int8 references users(id) not null,
       primary key (id));;

/* A table linking pages and subjects */

create table subject_pages (
       subject_id int8 not null references subjects(id),
       page_id int8 not null references pages(id),
       primary key (subject_id, page_id));;

/* A table that tracks group files */

create table group_files (
       group_id int8 references groups(id) not null,
       file_id int8 references files(id) on delete cascade not null,
       primary key (group_id, file_id));;

/* A table that tracks subjects watched by a group  */

create table group_watched_subjects (
       group_id int8 references groups(id) not null,
       subject_id int8 not null references subjects(id),
       primary key (group_id, subject_id));;

/* A table for group mailing list emails */

create table group_mailing_list_messages (
       id bigserial not null unique,
       message_id varchar(320) not null,
       group_id int8 references groups(id) not null,
       sender_email varchar(320),
       reply_to_message_id varchar(320) default null,
       reply_to_group_id int8 references groups(id) default null,
       thread_message_id varchar(320) not null,
       thread_group_id int8 references groups(id) not null,
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
        new_group_id int8 := NULL;
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
       group_id int8 not null,
       file_id int8 references files(id) not null,
       foreign key (message_id, group_id) references group_mailing_list_messages,
       primary key (message_id, group_id, file_id));;

/* A table for search indexing */
create table search_items (
       id bigserial not null,
       content_item_id int8 not null references content_items(id),
       terms tsvector,
       location_id int8 references tags(id) default null,
       primary key (id));;

create index search_items_idx on search_items using gin(terms);;

CREATE FUNCTION update_group_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT id INTO search_id  FROM search_items WHERE content_item_id = NEW.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.description, ''))
          || to_tsvector(coalesce(NEW.page, '')),
          location_id = NEW.location_id
          WHERE id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms, location_id) VALUES (NEW.id,
          to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.description, ''))
          || to_tsvector(coalesce(NEW.page, '')),
          NEW.location_id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER update_group_search AFTER INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE update_group_search();;

CREATE FUNCTION update_page_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT id INTO search_id  FROM search_items WHERE content_item_id = NEW.page_id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.content,'')) WHERE id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (NEW.page_id,
          to_tsvector(coalesce(NEW.title,'')) || to_tsvector(coalesce(NEW.content, '')));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_page_search AFTER INSERT OR UPDATE ON page_versions
    FOR EACH ROW EXECUTE PROCEDURE update_page_search();;

CREATE FUNCTION update_subject_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT id INTO search_id  FROM search_items WHERE content_item_id = NEW.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.lecturer,'')),
          location_id = NEW.location_id WHERE id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, location_id, terms) VALUES (NEW.id, NEW.location_id,
          to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.lecturer, '')));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_subject_search AFTER INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_search();;

/* A table for connecting tags and the tagged content */
create table content_tags (id bigserial not null,
       content_item_id int8 not null references content_items(id) on delete cascade,
       tag_id int8 references tags(id) not null,
       primary key (id));;

/* A trigger for updating page tags and location tags - they are taken from their parent subject */
CREATE FUNCTION update_page_tags() RETURNS trigger AS $$
    DECLARE
      mtag_id int8 := NULL;
      mpage_id int8 := NULL;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        /* the tag was deleted, unalias it from all the subject's pages */
        DELETE FROM content_tags t USING subject_pages p
          WHERE t.content_item_id = p.page_id
          AND p.subject_id = OLD.content_item_id
          AND t.tag_id = OLD.tag_id;
        RETURN OLD;
      ELSIF TG_OP = 'INSERT' THEN
        FOR mpage_id IN SELECT page_id FROM subject_pages WHERE subject_id = NEW.content_item_id LOOP
          SELECT id INTO mtag_id FROM content_tags WHERE content_item_id = mpage_id AND tag_id = NEW.tag_id;
          IF NOT FOUND THEN
            INSERT INTO content_tags (content_item_id, tag_id) VALUES (mpage_id, NEW.tag_id);
          END IF;
        END LOOP;
        RETURN NEW;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_page_tags BEFORE INSERT OR DELETE ON content_tags
    FOR EACH ROW EXECUTE PROCEDURE update_page_tags();;

/* a trigger to set the page's tags to the parent subject's tags on page creation */
CREATE FUNCTION set_page_tags() RETURNS trigger AS $$
    BEGIN
      DELETE FROM content_tags WHERE content_item_id = NEW.page_id;
      INSERT INTO content_tags (content_item_id, tag_id) SELECT NEW.page_id, tag_id FROM content_tags
        WHERE content_item_id = NEW.subject_id;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_page_tags BEFORE INSERT ON subject_pages
    FOR EACH ROW EXECUTE PROCEDURE set_page_tags();;

/* a trigger to set the page's location based on the location of the subject the page belongs to*/
/* a trigger to set the page's tags to the parent subject's tags on page creation */
CREATE FUNCTION set_page_location() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
        subject_location_id int8 := NULL;
    BEGIN
      SELECT location_id INTO subject_location_id FROM subjects WHERE id = NEW.subject_id;
      UPDATE pages SET location_id = subject_location_id WHERE id = NEW.page_id;

      SELECT id INTO search_id  FROM search_items WHERE content_item_id = NEW.page_id;
      IF FOUND THEN
        UPDATE search_items SET location_id = subject_location_id WHERE content_item_id = NEW.page_id;
      ELSE
        INSERT INTO search_items (content_item_id, location_id) VALUES (NEW.page_id, subject_location_id);
      END IF;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_page_location AFTER INSERT ON subject_pages
    FOR EACH ROW EXECUTE PROCEDURE set_page_location();;

/* a trigger to update the page's tags when the subject's location changes */
CREATE FUNCTION update_page_location() RETURNS trigger AS $$
    BEGIN
      UPDATE pages SET location_id = NEW.location_id
        FROM pages p JOIN subject_pages s
        ON p.id = s.page_id
        WHERE s.subject_id = NEW.id;
      RETURN NEW;
      UPDATE search_items SET location_id = NEW.location_id
        FROM search_items si
        JOIN subject_pages sp
        ON si.id = sp.page_id
        WHERE sp.subject_id = NEW.id;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_page_location AFTER UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE update_page_location();;
