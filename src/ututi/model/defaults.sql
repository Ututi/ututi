
create table users (
       id bigserial not null,
       fullname varchar(100),
       password char(36),
       site_url varchar(200) default null,
       description text default null,
       last_seen timestamp not null default (now() at time zone 'UTC'),
       recovery_key varchar(10) default null,
       logo bytea default null,
       accepted_terms timestamp default null,
       receive_email_each varchar(30) default 'day',
       gadugadu_uin bigint default null,
       gadugadu_confirmed boolean default false,
       gadugadu_confirmation_key char(32) default '',
       gadugadu_get_news boolean default false,
       primary key (id));;

CREATE FUNCTION check_gadugadu() RETURNS trigger AS $$
    BEGIN
        IF NEW.gadugadu_uin is NULL THEN
          NEW.gadugadu_confirmed := false;
          NEW.gadugadu_confirmation_key := '';
          NEW.gadugadu_get_news := false;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER check_gadugadu BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE check_gadugadu();;

/* Create first user=admin and password=asdasd */
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

/* A generic table for Ututi objects */
create table content_items (id bigserial not null,
       content_type varchar(20) not null default '',
       created_by int8 references users(id) not null,
       created_on timestamp not null default (now() at time zone 'UTC'),
       modified_by int8 references users(id) default null,
       modified_on timestamp not null default (now() at time zone 'UTC'),
       deleted_by int8 references users(id) default null,
       deleted_on timestamp default null,
       primary key (id));;

CREATE FUNCTION set_deleted_on() RETURNS trigger AS $$
    BEGIN
        IF not NEW.deleted_by is NULL AND OLD.deleted_by is NULL THEN
          NEW.deleted_on := (now() at time zone 'UTC');
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_deleted_on BEFORE UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE set_deleted_on();;

/* A table for files */
create table files (id int8 references content_items(id),
       md5 char(32),
       folder varchar(255) default '' not null,
       mimetype varchar(255) default 'application/octet-stream',
       filesize int8,
       filename varchar(500),
       title varchar(500),
       description text default '',
       parent_id int8 default null references content_items(id) on delete set null,
       primary key (id));;

create index md5 on files (md5);;

create table file_downloads (file_id int8 references content_items(id) on delete cascade,
       user_id int8 references users(id),
       download_time timestamp not null default (now() at time zone 'UTC'),
       primary key(file_id, user_id, download_time));;

create index user_id on file_downloads (user_id);;
create index file_id on file_downloads (file_id);;

/* A table for tags (location and simple tags) */
create table tags (id bigserial not null,
       parent_id int8 default null references tags(id) on delete cascade,
       title varchar(250) not null,
       title_short varchar(50) default null,
       description text default null,
       site_url varchar(200) default null,
       logo bytea default null,
       tag_type varchar(10) default null,
       confirmed bool default true,
       primary key (id));;

insert into tags (title, title_short, description, tag_type)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.', 'location');;
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('Ekonomikos fakultetas', 'ef', '', 1, 'location');;

/* Add location field to the content item table */
alter table content_items add column location_id int8 default null references tags(id) on delete set null;;

/* A table for groups */
create table groups (
       id int8 references content_items(id),
       group_id varchar(250) not null unique,
       title varchar(250) not null,
       year date not null,
       description text,
       show_page bool default true,
       page text not null default '',
       logo bytea default null,
       moderators bool default false,
       default_tab varchar(20) default 'home',
       primary key (id));;

/* An enumerator for membership types in groups */
create table group_membership_types (
       membership_type varchar(20) not null,
       primary key (membership_type));;


/* A table that tracks user membership in groups */
create table group_members (
       group_id int8 references groups(id) on delete cascade not null,
       user_id int8 references users(id) not null,
       membership_type varchar(20) references group_membership_types(membership_type) not null,
       subscribed bool default true,
       receive_email_each varchar(30) default 'day',
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
       description text default null,
       primary key (id));;

/* A table that tracks subjects watched and ignored by a user */

create table user_monitored_subjects (
       user_id int8 references users(id) not null,
       subject_id int8 not null references subjects(id),
       ignored bool default false,
       primary key (user_id, subject_id, ignored));;

/* A table for pages */

create table pages (
       id int8 not null references content_items(id),
       primary key(id));;

create table page_versions(id int8 not null references content_items(id),
       page_id int8 references pages(id) not null,
       title varchar(255) not null default '',
       content text not null default '',
       primary key (id));;

/* A table linking pages and subjects */

create table subject_pages (
       subject_id int8 not null references subjects(id),
       page_id int8 not null references pages(id),
       primary key (subject_id, page_id));;

/* A table that tracks subjects watched by a group  */

create table group_watched_subjects (
       group_id int8 references groups(id) on delete cascade not null,
       subject_id int8 not null references subjects(id),
       primary key (group_id, subject_id));;

/* A table for group mailing list emails */

create table group_mailing_list_messages (
       id int8 references content_items(id) unique,
       message_id varchar(320) not null,
       group_id int8 references groups(id) on delete cascade not null,
       sender_email varchar(320),
       reply_to_message_id varchar(320) default null,
       reply_to_group_id int8 references groups(id) on delete cascade default null,
       thread_message_id varchar(320) not null,
       thread_group_id int8 references groups(id) on delete cascade not null,
       author_id int8 references users(id) not null,
       subject varchar(500) not null,
       original text not null,
       sent timestamp not null,
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


CREATE TRIGGER set_thread_id BEFORE INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE set_thread_id();;


/* A table that tracks attachments for messages */

create table group_mailing_list_attachments (
       message_id varchar(320) not null,
       group_id int8 not null,
       file_id int8 references files(id) not null,
       foreign key (message_id, group_id) references group_mailing_list_messages on delete cascade,
       primary key (message_id, group_id, file_id));;

/* A table for search indexing */
create table search_items (
       content_item_id int8 not null references content_items(id) on delete cascade,
       terms tsvector,
       primary key (content_item_id));;

create index search_items_idx on search_items using gin(terms);;

CREATE FUNCTION update_group_worker(groups) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        grp ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = grp.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(grp.title,''))
          || to_tsvector(coalesce(grp.description, ''))
          || to_tsvector(coalesce(grp.page, ''))
          || to_tsvector(coalesce(grp.group_id, ''))
           WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (grp.id,
          to_tsvector(coalesce(grp.title,''))
          || to_tsvector(coalesce(grp.description, ''))
          || to_tsvector(coalesce(grp.group_id, ''))
          || to_tsvector(coalesce(grp.page, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_group_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_group_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_group_search AFTER INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE update_group_search();;


CREATE FUNCTION update_page_worker(page_versions) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        page ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = page.page_id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(page.title,''))
          || to_tsvector(coalesce(page.content,'')) WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (page.page_id,
          to_tsvector(coalesce(page.title,'')) || to_tsvector(coalesce(page.content, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_page_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_page_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_page_search AFTER INSERT OR UPDATE ON page_versions
    FOR EACH ROW EXECUTE PROCEDURE update_page_search();;


CREATE FUNCTION update_subject_worker(subjects) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        subject ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = subject.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(subject.title,''))
          || to_tsvector(coalesce(subject.lecturer,''))
          || to_tsvector(coalesce(subject.description,''))
          WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (subject.id,
          to_tsvector(coalesce(subject.title,''))
          || to_tsvector(coalesce(subject.description,''))
          || to_tsvector(coalesce(subject.lecturer, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_subject_search() RETURNS trigger AS $$
    BEGIN
        PERFORM update_subject_worker(NEW);
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

/* a trigger to set the page's location based on the location of the subject the page belongs to*/
CREATE FUNCTION set_file_location() RETURNS trigger AS $$
    DECLARE
        parent_location_id int8 := NULL;
    BEGIN
      SELECT location_id INTO parent_location_id FROM content_items WHERE id = NEW.parent_id;
      UPDATE content_items SET location_id = parent_location_id WHERE id = NEW.id;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_file_location AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE set_file_location();;

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
      SELECT location_id INTO subject_location_id FROM content_items WHERE id = NEW.subject_id;
      UPDATE content_items SET location_id = subject_location_id WHERE id = NEW.page_id;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_page_location AFTER INSERT ON subject_pages
    FOR EACH ROW EXECUTE PROCEDURE set_page_location();;

/* a trigger to update the page's tags when the subject's location changes */
CREATE FUNCTION update_page_location() RETURNS trigger AS $$
    BEGIN
      IF NEW.content_type <> 'subject' THEN
        RETURN NEW;
      END IF;
      UPDATE content_items SET location_id = NEW.location_id
             FROM subject_pages s
             WHERE s.page_id = id
             AND s.subject_id = NEW.id;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_page_location AFTER UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE update_page_location();;

/* a trigger to update the date and user who created the object */
CREATE FUNCTION on_content_create() RETURNS trigger AS $$
    BEGIN
      NEW.created_by = current_setting('ututi.active_user');
      NEW.created_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER on_content_create BEFORE INSERT ON content_items
    FOR EACH ROW EXECUTE PROCEDURE on_content_create();;

/* a trigger to update the date and user who modified the object */
CREATE FUNCTION on_content_update() RETURNS trigger AS $$
    BEGIN
      NEW.modified_by = current_setting('ututi.active_user');
      NEW.modified_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER on_content_update AFTER UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE on_content_update();;


/* Events */
create table events (
       id bigserial not null,
       object_id int8 default null references content_items(id) on delete cascade not null,
       author_id int8 references users(id) not null,
       created timestamp not null default (now() at time zone 'UTC'),
       event_type varchar(30),
       file_id int8 references files(id) on delete cascade default null,
       page_id int8 references pages(id) on delete cascade default null,
       subject_id int8 references subjects(id) on delete cascade default null,
       message_id int8 references group_mailing_list_messages(id) on delete cascade default null,
       primary key (id));;


CREATE FUNCTION add_event(id int8, evtype varchar) RETURNS void AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (id, cast(current_setting('ututi.active_user') as int8), evtype);
    END
$$ LANGUAGE plpgsql;;


/* page events */
CREATE FUNCTION page_modified_trigger() RETURNS trigger AS $$
    DECLARE
      version_count int8 := NULL;
      sid int8 := NULL;
    BEGIN
      SELECT count(*) INTO version_count FROM page_versions WHERE page_id = NEW.page_id;
      IF version_count > 1 THEN
        SELECT subject_id INTO sid FROM subject_pages WHERE page_id = NEW.page_id;
        IF FOUND THEN
          INSERT INTO events (object_id, author_id, event_type, page_id)
                 VALUES (sid, cast(current_setting('ututi.active_user') as int8), 'page_modified', NEW.page_id);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER page_modified_trigger AFTER INSERT OR UPDATE ON page_versions
    FOR EACH ROW EXECUTE PROCEDURE page_modified_trigger();;


CREATE FUNCTION subject_page_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, page_id)
             VALUES (NEW.subject_id, cast(current_setting('ututi.active_user') as int8), 'page_created', NEW.page_id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER subject_page_event_trigger AFTER INSERT OR UPDATE ON subject_pages
    FOR EACH ROW EXECUTE PROCEDURE subject_page_event_trigger();;


CREATE FUNCTION file_event_trigger() RETURNS trigger AS $$
    DECLARE parent_type varchar(20) := NULL;
    BEGIN
      IF NOT NEW.parent_id is NULL THEN
        IF TG_OP = 'UPDATE' THEN
          IF OLD.parent_id = NEW.parent_id THEN
            RETURN NEW;
          END IF;
        END IF;
        SELECT content_type INTO parent_type FROM content_items WHERE id = NEW.parent_id;
        IF parent_type in ('subject', 'group') THEN
          INSERT INTO events (object_id, author_id, event_type, file_id)
                 VALUES (NEW.parent_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.id);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER file_event_trigger AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE file_event_trigger();;


CREATE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
      eid int8 := NULL;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          SELECT id INTO eid FROM events WHERE object_id = NEW.id AND event_type = 'subject_created';
          IF NOT FOUND THEN
              EXECUTE add_event(NEW.id, cast('subject_created' as varchar));
          END IF;
      ELSE
         EXECUTE add_event(NEW.id, cast('subject_modified' as varchar));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER subject_event_trigger BEFORE INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE subject_event_trigger();;

CREATE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, message_id)
             VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'forum_post_created', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER group_mailing_list_message_event_trigger AFTER INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE group_mailing_list_message_event_trigger();;


CREATE FUNCTION member_group_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF TG_OP = 'DELETE' THEN
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (OLD.group_id, OLD.user_id, 'member_left');
      ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (NEW.group_id, NEW.user_id, 'member_joined');
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER member_group_event_trigger AFTER INSERT OR DELETE ON group_members
    FOR EACH ROW EXECUTE PROCEDURE member_group_event_trigger();;

CREATE FUNCTION group_subject_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF TG_OP = 'DELETE' THEN
        INSERT INTO events (object_id, subject_id, author_id, event_type)
               VALUES (OLD.group_id, OLD.subject_id, cast(current_setting('ututi.active_user') as int8), 'group_stopped_watching_subject');
      ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO events (object_id, subject_id, author_id, event_type)
               VALUES (NEW.group_id, NEW.subject_id, cast(current_setting('ututi.active_user') as int8), 'group_started_watching_subject');
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER group_subject_event_trigger AFTER INSERT OR DELETE ON group_watched_subjects
    FOR EACH ROW EXECUTE PROCEDURE group_subject_event_trigger();;


/* Table for storing invitations to a group */
CREATE TABLE group_invitations (
       created timestamp not null default (now() at time zone 'UTC'),
       email varchar(320) default null,
       user_id int8 references users(id) default null,
       group_id int8 not null references groups(id) on delete cascade,
       author_id int8 not null references users(id),
       hash varchar(32) not null unique,
       primary key (hash),
       unique(group_id, email));;

/* Table for storing requests to join a group */
CREATE TABLE group_requests (
       created timestamp not null default (now() at time zone 'UTC'),
       user_id int8 references users(id) default null,
       group_id int8 not null references groups(id) on delete cascade,
       hash char(8) not null unique,
       primary key (hash));;


CREATE TABLE forum_posts (
       id int8 not null references content_items(id),
       thread_id int8 not null references forum_posts,
       forum_id varchar(100) default null,
       title varchar(500) not null,
       message text not null,
       parent_id int8 default null references content_items(id) on delete cascade,
       primary key(id));;


CREATE FUNCTION set_forum_thread_id() RETURNS trigger AS $$
    BEGIN
        IF NEW.thread_id is NULL THEN
          NEW.thread_id := NEW.id;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER set_forum_thread_id BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE set_forum_thread_id();;

/* blog entries */
create table blog (
       id bigserial not null,
       content text not null default '',
       created date not null default (now() at time zone 'UTC'),
       primary key (id));;
