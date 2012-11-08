create table languages (
       id varchar(100) not null,
       title varchar(100) not null,
       primary key (id));;

create table language_texts (
       id varchar(100) not null,
       language_id varchar(100) not null references languages(id) on delete cascade,
       text text not null default '',
       primary key (id, language_id));;

create table i18n_texts (
       id bigserial not null,
       primary key (id));

/* Creates a new i18n_text object and returns it's id. */
CREATE FUNCTION create_i18n_text() RETURNS int8 AS $$
    BEGIN
        INSERT INTO i18n_texts DEFAULT VALUES;
        RETURN currval(pg_get_serial_sequence('i18n_texts', 'id'));
    END
$$ LANGUAGE plpgsql;;

create table i18n_texts_versions (
       i18n_texts_id int8 not null references i18n_texts(id) on delete cascade,
       language_id varchar(100) not null references languages(id) on delete cascade,
       text text not null default '',
       primary key (i18n_texts_id, language_id));;


create table countries (
       id bigserial not null,
       name varchar(100) not null,
       timezone varchar(100) default 'UTC' not null,
       locale varchar(30) not null,
       language_id varchar(100) not null references languages(id) on delete cascade,
       primary key (id));;

/* A table for custom Ututi theming data.
 */
CREATE TABLE themes (
       id bigserial not null,
       header_background_color varchar(6) default null,
       header_color varchar(6) default null,
       header_logo bytea default null,
       header_text varchar(100) default null,
       primary key (id));;

create table admin_users(
       id bigserial not null,
       email varchar(320),
       fullname varchar(100),
       password char(36),
       last_seen timestamp not null default (now() at time zone 'UTC'),
       primary key (id));;

create table authors (
       id bigserial not null,
       type varchar(20) not null default 'nouser',
       fullname varchar(100),
       primary key (id));;

create table users (
       id int8 references authors(id) on delete cascade,
       username varchar(320) not null, /* email actually */
       password char(36),
       site_url varchar(200) default null,
       description text default null,
       last_seen timestamp not null default (now() at time zone 'UTC'),
       recovery_key varchar(10) default null,
       logo bytea default null,
       accepted_terms timestamp default null,
       receive_email_each varchar(30) default 'day',
       openid varchar(200) default null unique,
       facebook_id bigint default null unique,
       phone_number varchar(20) default null,
       phone_confirmed boolean default false,
       phone_confirmation_key char(32) default '',
       sms_messages_remaining int8 default 30,
       profile_is_public boolean default true,
       email_is_public boolean default false,
       hidden_blocks text default '',
       last_seen_feed timestamp not null default (now() at time zone 'UTC'),
       location_country varchar(5) default null,
       location_city varchar(30) default null,
       ignored_events text default '',
       url_name varchar(200) default null unique, /* ututi username, used in urls */
       primary key (id));;

create table teachers (
       id int8 references users(id) on delete cascade,
       teacher_verified boolean default null,
       teacher_position varchar(200) default null,
       work_address varchar(200) default null,
       publications text default null,
       general_info_id int8 not null references i18n_texts(id) on delete restrict,
       primary key (id));;


CREATE FUNCTION teacher_insert_trg() RETURNS TRIGGER AS $$
    BEGIN
        NEW.general_info_id := create_i18n_text();
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER teacher_insert_trg BEFORE INSERT ON teachers FOR EACH ROW
    EXECUTE PROCEDURE teacher_insert_trg();

CREATE FUNCTION teacher_delete_trg() RETURNS trigger AS $$
    BEGIN
        DELETE FROM i18n_texts WHERE id = OLD.general_info_id;
        RETURN NULL;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER teacher_delete_trg AFTER DELETE ON teachers FOR EACH ROW
    EXECUTE PROCEDURE teacher_delete_trg();

CREATE FUNCTION delete_user() RETURNS trigger AS $$
    BEGIN
        UPDATE authors SET type = 'nouser' WHERE id = OLD.id;
        RETURN OLD;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER delete_user BEFORE DELETE ON users
    FOR EACH ROW EXECUTE PROCEDURE delete_user();;


/* Storing the emails of the users. */
create table emails (
       id int8 not null references users(id) on delete cascade,
       email varchar(320),
       confirmed boolean default FALSE,
       confirmation_key char(32) default '',
       primary key (id, email));;


CREATE FUNCTION lowercase_email() RETURNS trigger AS $lowercase_email$
    BEGIN
        NEW.email := lower(NEW.email);
        RETURN NEW;
    END
$lowercase_email$ LANGUAGE plpgsql;;


CREATE TRIGGER lowercase_email BEFORE INSERT OR UPDATE ON emails
    FOR EACH ROW EXECUTE PROCEDURE lowercase_email();;


/* user medals */
create table user_medals (
       id bigserial not null,
       user_id int8 default null references users(id) on delete cascade,
       medal_type varchar(30) not null,
       awarded_on timestamp not null default (now() at time zone 'UTC'),
       primary key (id),
       unique(user_id, medal_type));;

create index user_medals_user_id on user_medals(user_id);

/* A generic table for Ututi objects */
create table content_items (
       id bigserial not null,
       content_type varchar(20) not null default '',
       created_by int8 references authors(id) on delete set null,
       created_on timestamp not null default (now() at time zone 'UTC'),
       modified_by int8 references authors(id) on delete set null default null,
       modified_on timestamp not null default (now() at time zone 'UTC'),
       deleted_by int8 references authors(id) on delete cascade default null,
       deleted_on timestamp default null,
       location_id int8 default null,
       primary key (id));;

CREATE FUNCTION set_deleted_on() RETURNS trigger AS $$
    BEGIN
        IF not NEW.deleted_by is NULL AND OLD.deleted_by is NULL THEN
          NEW.deleted_on := (now() at time zone 'UTC');
        ELSIF NEW.deleted_by is NULL AND NOT OLD.deleted_by is NULL THEN
          NEW.deleted_on := NULL;
        END IF;

        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_deleted_on BEFORE UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE set_deleted_on();;

/* private messages */
CREATE TABLE private_messages (
       id int8 references content_items(id) on delete cascade,
       sender_id int8 not null references users(id) on delete cascade,
       recipient_id int8 not null references users(id) on delete cascade,
       thread_id int8 default null references private_messages(id),
       subject varchar(500) not null,
       content text default '',
       is_read boolean default false,
       hidden_by_sender boolean default false,
       hidden_by_recipient boolean default false,
       primary key (id));;

CREATE INDEX sender_id ON private_messages (sender_id);;
CREATE INDEX recipient_id ON private_messages (recipient_id);;

/* A table for files */
create table files (
       id int8 references content_items(id) on delete cascade,
       md5 char(32),
       folder varchar(255) default '' not null,
       mimetype varchar(255) default 'application/octet-stream',
       filesize int8,
       filename varchar(500),
       title varchar(500),
       description text default '',
       parent_id int8 default null references content_items(id) on delete set null,
       primary key (id));;

create index files_parent_id_idx on files(parent_id);
create index md5 on files (md5);;

create table file_downloads (file_id int8 references files(id) on delete cascade,
       user_id int8 references users(id) on delete cascade,
       download_time timestamp not null default (now() at time zone 'UTC'),
       range_start int8 default null,
       range_end int8 default null,
       primary key(file_id, user_id, download_time));;

create index file_downloads_user_id_idx on file_downloads(user_id);

create index user_id on file_downloads (user_id);;
create index file_id on file_downloads (file_id);;

/* A table for regions */
create table regions (
       id bigserial not null,
       title varchar(250) not null,
       country varchar(2) not null,
       primary key (id));;

CREATE TYPE university_member_policy AS ENUM ('RESTRICT_EMAIL', 'ALLOW_INVITES', 'PUBLIC');

/* A table for tags (location and simple tags) */
create table tags (
       id bigserial not null,
       title varchar(250) not null,
       title_short varchar(50) default null,
       description text default null,
       logo bytea default null,
       tag_type varchar(10) default null,
       site_url varchar(200) default null,
       confirmed bool default true,
       member_policy university_member_policy default null,
       region_id int8 default null references regions(id) on delete restrict,
       parent_id int8 default null references tags(id) on delete cascade,
       country_id int8 default null references countries(id) on delete cascade,
       theme_id int8 default null references themes(id) on delete set null,
       teachers_url varchar default '' not null,
       primary key (id),
       unique(parent_id, title));;

alter table tags add constraint location_member_policy_not_null check (member_policy is not null or tag_type != 'location');;

CREATE FUNCTION tag_title_lowercase() RETURNS trigger AS $tag_parent$
    BEGIN
        NEW.title_short = LOWER(NEW.title_short);
        RETURN NEW;
    END
$tag_parent$ LANGUAGE plpgsql;;

CREATE TRIGGER tag_title_lowercase BEFORE INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE tag_title_lowercase();;

create unique index parent_title_unique_idx on tags(coalesce(parent_id, 0), title_short);;

alter table users add column location_id int8 not null references tags(id) on delete cascade;;
alter table users add column is_local_admin bool not null default false;
alter table users add constraint user_unique_pair unique (location_id, username);

create index user_location_idx on users using btree (location_id);

/* Add location field to the content item table */
alter table content_items
      add constraint content_items_location_id_fkey
      foreign key (location_id) references tags(id) on delete cascade;;

/* A table for group coupons */
create table group_coupons (
       id varchar(20) not null,
       created timestamp not null default (now() at time zone 'UTC'),
       valid_until timestamp not null,
       action varchar(40) not null,
       credit_count int default null,
       day_count int default null,
       primary key (id));;

/* A table for groups */
create table groups (
       id int8 references content_items(id) on delete cascade,
       group_id varchar(250) not null unique,
       title varchar(250) not null,
       year date not null,
       description text,
       page text not null default '',
       logo bytea default null,
       moderators bool default false,
       default_tab varchar(20) default 'home',
       page_public bool default false,
       wants_to_watch_subjects bool default true,
       admins_approve_members bool default true,
       forum_is_public bool default false,
       mailinglist_enabled bool default true,
       has_file_area bool default true,
       private_files_lock_date timestamp default null,
       ending_period_notification_sent bool default false,
       out_of_space_notification_sent bool default false,
       mailinglist_moderated bool not null default true,
       primary key (id));;

/* group mailinglist whitelist */
create table group_whitelist (
       id bigserial not null,
       group_id int8 default null references groups(id) on delete cascade,
       email varchar(320) not null,
       primary key (id));;

/* track coupon usage */
create table coupon_usage (
       coupon_id varchar(20) not null references group_coupons(id),
       group_id int8 default null references groups(id) on delete cascade,
       user_id int8 not null references users(id) on delete cascade,
       primary key (coupon_id, user_id));;

/* An enumerator for membership types in groups */
create table group_membership_types (
       membership_type varchar(20) not null,
       primary key (membership_type));;


/* A table that tracks user membership in groups */
create table group_members (
       group_id int8 references groups(id) on delete cascade not null,
       user_id int8 references users(id) on delete cascade not null,
       membership_type varchar(20) not null references group_membership_types(membership_type) on delete cascade,
       subscribed bool default true,
       receive_email_each varchar(30) default 'day',
       subscribed_to_forum bool default false,
       primary key (group_id, user_id));;

create index group_members_group_id_idx on group_members(group_id);
create index group_members_user_id_idx on group_members(user_id);

/* A table for subjects */
create table subjects (
       id int8 not null references content_items(id) on delete cascade,
       sub_department_id int8 default null,
       subject_id varchar(150) default null,
       title varchar(500) not null,
       lecturer varchar(500) default null,
       description text default null,
       visibility varchar(40) not null default 'everyone',
       edit_settings_perm varchar(40) not null default 'everyone',
       post_discussion_perm varchar(40) not null default 'everyone',
       primary key (id));;

/* A table that tracks subjects watched and ignored by a user */

create table user_monitored_subjects (
       user_id int8 references users(id) on delete cascade not null,
       subject_id int8 not null references subjects(id) on delete cascade,
       ignored bool default false,
       primary key (user_id, subject_id, ignored));;

/* A table for pages */

create table pages (
       id int8 not null references content_items(id) on delete cascade,
       primary key(id));;

create table page_versions(
       id int8 not null references content_items(id) on delete cascade,
       page_id int8 not null references pages(id) on delete cascade,
       title varchar(255) not null default '',
       content text not null default '',
       primary key (id));;

/* A table linking pages and subjects */

create table subject_pages (
       subject_id int8 not null references subjects(id) on delete cascade,
       page_id int8 not null references pages(id) on delete cascade,
       primary key (subject_id, page_id));;

/* A table that tracks subjects watched by a group  */

create table group_watched_subjects (
       group_id int8 references groups(id) on delete cascade not null,
       subject_id int8 not null references subjects(id) on delete cascade,
       primary key (group_id, subject_id));;

/* A table for group mailing list emails */

create table group_mailing_list_messages (
       id int8 references content_items(id) unique,
       message_id varchar(320) not null,
       group_id int8 references groups(id) on delete cascade not null,
       sender_email varchar(320),
       reply_to_message_id varchar(320) default null,
       reply_to_group_id int8 references groups(id) on delete cascade default null,
       reply_to_message_machine_id int8 default null references group_mailing_list_messages(id) on delete cascade,
       thread_message_id varchar(320) not null,
       thread_group_id int8 references groups(id) on delete cascade not null,
       author_id int8 references users(id) on delete set null,
       thread_message_machine_id int8 not null references group_mailing_list_messages(id) on delete cascade,
       subject varchar(500) not null,
       original bytea not null,
       sent timestamp not null,
       in_moderation_queue boolean default false,
       primary key (message_id, group_id));;

CREATE INDEX group_mailing_list_messages_reply_to_idx ON group_mailing_list_messages USING btree (reply_to_group_id, reply_to_message_id);

CREATE INDEX group_mailing_list_messages_thread_idx ON group_mailing_list_messages USING btree (thread_group_id, thread_message_id);

CREATE FUNCTION set_thread_id() RETURNS trigger AS $$
    DECLARE
        lookup_id int8 := NULL;
        n_thread_group_id int8 := NULL;
        n_thread_message_id varchar(320) := NULL;
        n_thread_message_machine_id int8 := NULL;

        n_reply_to_message_id varchar(320) := NULL;
        n_reply_to_group_id int8 := NULL;

    BEGIN
        IF NEW.reply_to_message_machine_id is NULL THEN
          NEW.thread_message_id := NEW.message_id;
          NEW.thread_group_id := NEW.group_id;
          NEW.thread_message_machine_id := NEW.id;
        ELSE
          lookup_id := NEW.reply_to_message_machine_id;
          SELECT thread_message_id,
                 thread_group_id,
                 thread_message_machine_id,
                 message_id,
                 group_id
            INTO n_thread_message_id,
                 n_thread_group_id,
                 n_thread_message_machine_id,
                 n_reply_to_message_id,
                 n_reply_to_group_id
            FROM group_mailing_list_messages
            WHERE id = lookup_id;

          NEW.thread_message_id := n_thread_message_id;
          NEW.thread_group_id := n_thread_group_id;
          NEW.thread_message_machine_id := n_thread_message_machine_id;

          NEW.reply_to_message_id := n_reply_to_message_id;
          NEW.reply_to_group_id := n_reply_to_group_id;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_thread_id BEFORE INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE set_thread_id();;


create function delete_content_item() returns trigger as $$
    begin
        delete from content_items where content_items.id=OLD.id;
        RETURN NULL;
    end;
$$ language plpgsql;;

create trigger delete_content_item_after_group_delete after delete on group_mailing_list_messages
    for each row execute procedure delete_content_item();;

create trigger delete_content_item_after_page_version_delete after delete on page_versions
    for each row execute procedure delete_content_item();;

/* SMS */

CREATE TABLE outgoing_group_sms_messages (
       id bigserial not null,
       created timestamp not null default (now() at time zone 'UTC'),
       sender_id int8 not null references users(id) on delete cascade,
       group_id int8 not null references groups(id) on delete cascade,
       message_text text not null,
       primary key (id));


CREATE TABLE received_sms_messages (
       id bigserial not null,
       sender_id int8 references users(id) on delete cascade,
       group_id int8 references groups(id) on delete cascade,
       sender_phone_number varchar(20) default null,
       message_type varchar(30),
       message_text text,
       received timestamp not null default (now() at time zone 'UTC'),
       success boolean default null,
       result text,
       request_url text,
       test boolean default false,
       primary key (id));

CREATE TABLE sms_outbox (
       id bigserial not null,
       sender_uid int8 references users(id) on delete cascade not null,
       recipient_uid int8 references users(id) on delete cascade default null,
       recipient_number varchar(20),
       message_text text not null,
       created timestamp not null default (now() at time zone 'UTC'),
       processed timestamp default null,
       outgoing_group_message_id int8 references outgoing_group_sms_messages(id) on delete cascade,
       delivered timestamp default null,
       sending_status int default null,
       delivery_status int default null,
       primary key (id));

/* Forums */

CREATE TABLE forum_categories (
       id bigserial not null,
       group_id int8 null references groups(id) on delete cascade,
       title varchar(255) not null default '',
       description text not null default '',
       primary key (id));

CREATE INDEX forum_categories_group_id_idx ON forum_categories(group_id);


CREATE TABLE forum_posts (
       id int8 not null references content_items(id) on delete cascade,
       thread_id int8 not null references forum_posts on delete cascade,
       title varchar(500) not null,
       message text not null,
       parent_id int8 default null references content_items(id) on delete cascade,
       category_id int8 not null references forum_categories(id) on delete cascade,
       primary key(id));;

CREATE INDEX forum_posts_thread_id ON forum_posts(thread_id);
CREATE INDEX forum_posts_parent_id ON forum_posts(parent_id);
CREATE INDEX forum_posts_category_id ON forum_posts(category_id);

CREATE TABLE seen_threads (
       thread_id int8 not null references forum_posts on delete cascade,
       user_id int8 not null references users(id) on delete cascade,
       visited_on timestamp not null default '2000-01-01',
       primary key(thread_id, user_id));;

CREATE TABLE subscribed_threads (
       thread_id int8 not null references forum_posts on delete cascade,
       user_id int8 not null references users(id) on delete cascade,
       active boolean default true,
       primary key(thread_id, user_id));;

CREATE INDEX subscribed_threads_user_id ON subscribed_threads(user_id);


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
       rating int not null default 0,
       primary key (content_item_id));;

create index search_items_idx on search_items using gin(terms);;

CREATE FUNCTION update_group_worker(groups) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        grp ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(grp.id);
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
      EXECUTE set_ci_modtime(page.page_id);
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

CREATE FUNCTION update_file_worker(files) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        parent_type varchar(20) := NULL;
        file ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(file.id);
      SELECT ci.content_type INTO parent_type FROM content_items ci WHERE ci.id = file.parent_id;
      IF parent_type = 'subject' THEN
        SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = file.id;
        IF FOUND THEN
          UPDATE search_items SET terms = to_tsvector(coalesce(file.title,''))
            || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')) WHERE content_item_id=search_id;
        ELSE
          INSERT INTO search_items (content_item_id, terms) VALUES (file.id,
            to_tsvector(coalesce(file.title,'')) || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')));
        END IF;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_file_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_file_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_file_search AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE update_file_search();;

CREATE FUNCTION update_subject_worker(subjects) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        subject ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(subject.id);
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

CREATE FUNCTION update_forum_post_worker(forum_posts) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        post ALIAS FOR $1;
        category forum_categories;
        grp groups;
    BEGIN
      EXECUTE set_ci_modtime(post.id);
      SELECT * INTO category FROM forum_categories WHERE id = post.category_id;
      SELECT * INTO grp FROM groups WHERE id = category.group_id AND forum_is_public = TRUE;
      IF FOUND OR category.group_id IS NULL THEN
        SELECT content_item_id INTO search_id FROM search_items WHERE content_item_id = post.id;
        IF FOUND THEN
          UPDATE search_items SET terms = to_tsvector(coalesce(post.title,''))
            || to_tsvector(coalesce(post.message,'')) WHERE content_item_id=search_id;
        ELSE
          INSERT INTO search_items (content_item_id, terms) VALUES (post.id,
            to_tsvector(coalesce(post.title,'')) || to_tsvector(coalesce(post.message, '')));
        END IF;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_forum_post_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_forum_post_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_forum_post_search AFTER INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE update_forum_post_search();;

/* A table for connecting tags and the tagged content */
create table content_tags (
       id bigserial not null,
       content_item_id int8 not null references content_items(id) on delete cascade,
       tag_id int8 references tags(id) on delete cascade not null,
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

/* a trigger to update the page and file tags when the subject's location changes */
CREATE FUNCTION update_item_location() RETURNS trigger AS $$
    BEGIN
      IF (NEW.content_type <> 'subject' AND NEW.content_type <> 'group') OR NEW.location_id = OLD.location_id THEN
        RETURN NEW;
      END IF;
      UPDATE content_items SET location_id = NEW.location_id
             FROM subject_pages s
             WHERE s.page_id = id
             AND s.subject_id = NEW.id;
      UPDATE content_items ci set location_id = NEW.location_id
             FROM files f
             WHERE f.id = ci.id
             AND f.parent_id = NEW.id;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_item_location AFTER UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE update_item_location();;

/* a trigger to update the date and user who created the object */
CREATE FUNCTION on_content_create() RETURNS trigger AS $$
    BEGIN
      IF (current_setting('ututi.active_user') <> '') THEN
        NEW.created_by = current_setting('ututi.active_user');
      ELSE
        NEW.created_by = NULL;
      END IF;
      NEW.created_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER on_content_create BEFORE INSERT ON content_items
    FOR EACH ROW EXECUTE PROCEDURE on_content_create();;

/* a trigger to update the date and user who modified the object */
CREATE FUNCTION on_content_update() RETURNS trigger AS $$
    BEGIN
      IF (current_setting('ututi.active_user') <> '') THEN
        IF CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
          NEW.modified_by = current_setting('ututi.active_user');
          NEW.modified_on = (now() at time zone 'UTC');
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER on_content_update BEFORE UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE on_content_update();;


/* Events */
create table events (
       id bigserial not null,
       object_id int8 default null references content_items(id) on delete cascade,
       author_id int8 references users(id) on delete cascade,
       recipient_id int8 default null references users(id) on delete cascade,
       created timestamp not null default (now() at time zone 'UTC'),
       last_activity timestamp not null default (now() at time zone 'UTC'),
       event_type varchar(30),
       file_id int8 references files(id) on delete cascade default null,
       page_id int8 references pages(id) on delete cascade default null,
       subject_id int8 references subjects(id) on delete cascade default null,
       message_id int8 references group_mailing_list_messages(id) on delete cascade default null,
       post_id int8 references forum_posts(id) on delete cascade default null,
       sms_id int8 references outgoing_group_sms_messages(id) on delete cascade default null,
       private_message_id int8 references private_messages(id) on delete cascade default null,
       data text default null,
       parent_id int8 default null references events(id) on delete cascade,
       primary key (id));;

create index events_author_id_idx on events(author_id);
CREATE INDEX events_parent_id_idx ON events(parent_id);
CREATE INDEX events_created_idx ON events(created);
create index event_parent_is_null on events(created, event_type) where parent_id is null;;

CREATE FUNCTION add_event(event_id int8, evtype varchar) RETURNS void AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype);
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION add_event_r(event_id int8, evtype varchar) RETURNS events AS $$
    DECLARE
      evt events;
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype)
             RETURNING * INTO evt;
      RETURN evt;
    END
$$ LANGUAGE plpgsql;;


CREATE FUNCTION set_ci_modtime(content_item_id int8) RETURNS void AS $$
    BEGIN
      IF (current_setting('ututi.active_user') <> '') AND
         CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
        UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
          modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
      END IF;
    END
$$ LANGUAGE plpgsql;;


/* event comments */
CREATE TABLE event_comments (
       id int8 references content_items(id) on delete cascade,
       event_id int8 not null references events(id) on delete cascade,
       content text default '',
       primary key (id));;

CREATE INDEX event_comments_event_id_idx ON event_comments (event_id);;

CREATE FUNCTION event_comment_created_trigger() RETURNS trigger AS $$
    BEGIN
        UPDATE events SET last_activity  = (now() at time zone 'UTC') WHERE id = NEW.event_id;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER after_event_comment_created AFTER INSERT ON event_comments
    FOR EACH ROW EXECUTE PROCEDURE event_comment_created_trigger();;

/* page events */
CREATE FUNCTION page_modified_trigger() RETURNS trigger AS $$
    DECLARE
      version_count int8 := NULL;
      sid int8 := NULL;
      evt events;
      pid int8 := NULL;
    BEGIN
      SELECT count(*) INTO version_count FROM page_versions WHERE page_id = NEW.page_id;
      IF version_count > 1 THEN
        SELECT subject_id INTO sid FROM subject_pages WHERE page_id = NEW.page_id;
        IF FOUND THEN
          INSERT INTO events (object_id, author_id, event_type, page_id)
                 VALUES (sid, cast(current_setting('ututi.active_user') as int8), 'page_modified', NEW.page_id)
                 RETURNING * INTO evt;
          EXECUTE event_set_group(evt);
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
    DECLARE
      parent_type varchar(20) := NULL;
      evt events;
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
                 VALUES (NEW.parent_id, cast(current_setting('ututi.active_user') as int8), 'file_uploaded', NEW.id)
                 RETURNING * INTO evt;
          EXECUTE event_set_group(evt);
        END IF;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER file_event_trigger AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE file_event_trigger();;


CREATE FUNCTION event_set_group(evt events) RETURNS void as $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF evt.event_type = 'subject_modified' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type in ('subject_modified', 'subject_created')
             AND e.object_id = evt.object_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'page_modified' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type in ('page_modified', 'page_created')
             AND e.object_id = evt.object_id
             AND e.page_id = evt.page_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'file_uploaded' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = 'file_uploaded'
             AND e.object_id = evt.object_id
             AND e.author_id = evt.author_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'member_joined' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = evt.event_type
             AND e.object_id = evt.object_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      ELSIF evt.event_type = 'member_left' THEN
         SELECT id INTO pid FROM events e WHERE e.event_type = evt.event_type
             AND e.object_id = evt.object_id
             AND evt.created - e.created < interval '15 minutes'
             AND e.parent_id IS NULL
             AND e.id <> evt.id
             AND e.created < evt.created
             ORDER BY e.created DESC
             LIMIT 1;
      END IF;
      IF evt.event_type IN ('subject_modified', 'page_modified', 'file_uploaded', 'member_joined', 'member_left') AND NOT pid IS null THEN
        UPDATE events SET parent_id = evt.id WHERE id = pid or parent_id = pid;
      END IF;
    END;
$$ LANGUAGE plpgsql;;

CREATE FUNCTION subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      sid int8 := NULL;
      eid int8 := NULL;
      evt events;
    BEGIN
      SELECT id INTO sid FROM subjects WHERE subject_id = NEW.subject_id;
      IF NOT FOUND THEN
          SELECT id INTO eid FROM events WHERE object_id = NEW.id AND event_type = 'subject_created';
          IF NOT FOUND THEN
              evt := add_event_r(NEW.id, cast('subject_created' as varchar));
          END IF;
      ELSE
         evt := add_event_r(NEW.id, cast('subject_modified' as varchar));
         EXECUTE event_set_group(evt);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER subject_event_trigger BEFORE INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE subject_event_trigger();;

CREATE FUNCTION group_creation_event_trigger() RETURNS trigger AS $$
    BEGIN
      EXECUTE add_event(NEW.id, cast('group_created' as varchar));
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_created_event_trigger BEFORE INSERT ON groups
    FOR EACH ROW EXECUTE PROCEDURE group_creation_event_trigger();;

CREATE FUNCTION get_group_mailing_list_message_event_parent(group_mailing_list_messages) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_message_id = obj.message_id AND obj.thread_group_id = obj.group_id THEN
            RETURN NULL; /* This message is root of the thread. */
        END IF;
        SELECT INTO id coalesce(evt.parent_id, evt.id) FROM events evt INNER JOIN group_mailing_list_messages msg
               ON msg.id = evt.message_id
               WHERE msg.message_id = obj.thread_message_id AND msg.group_id = obj.thread_group_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
      pid int8 := NULL;
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        pid := get_group_mailing_list_message_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id)
               RETURNING * INTO evt;
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_mailing_list_message_event_trigger AFTER INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE group_mailing_list_message_event_trigger();;

CREATE FUNCTION get_group_forum_post_event_parent(forum_posts) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id = obj.id THEN
            RETURN NULL; /* This post is root of the thread. */
        END IF;
        SELECT INTO id coalesce(evt.parent_id, evt.id) FROM events evt INNER JOIN forum_posts msg
               ON msg.id = evt.post_id
               WHERE msg.id = obj.thread_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
      pid int8 := NULL;
    BEGIN
      pid := get_group_forum_post_event_parent(NEW);
      INSERT INTO events (object_id, author_id, event_type, post_id)
             VALUES (
                (SELECT group_id FROM forum_categories
                 WHERE forum_categories.id = NEW.category_id),
                cast(current_setting('ututi.active_user') as int8),
                'forum_post_created', NEW.id)
             RETURNING * INTO evt;
      UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_forum_message_event_trigger AFTER INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE group_forum_message_event_trigger();;

CREATE FUNCTION member_group_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
      temp_id int8;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        SELECT u.id into temp_id FROM users u where u.id = OLD.user_id;
        IF NOT FOUND THEN
          RETURN NEW;
        END IF;
        SELECT g.id into temp_id FROM groups g where g.id = OLD.group_id;
        IF NOT FOUND THEN
          RETURN NEW;
        END IF;
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (OLD.group_id, OLD.user_id, 'member_left')
               RETURNING * INTO evt;
      ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO events (object_id, author_id, event_type)
               VALUES (NEW.group_id, NEW.user_id, 'member_joined')
               RETURNING * INTO evt;
      END IF;
      EXECUTE event_set_group(evt);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER member_group_event_trigger AFTER INSERT OR DELETE ON group_members
    FOR EACH ROW EXECUTE PROCEDURE member_group_event_trigger();;

CREATE FUNCTION group_subject_event_trigger() RETURNS trigger AS $$
    DECLARE
      temp_id int8;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        SELECT g.id into temp_id FROM groups g where g.id = OLD.group_id;
        IF NOT FOUND THEN
          RETURN NEW;
        END IF;
        SELECT s.id into temp_id FROM subjects s where s.id = OLD.subject_id;
        IF NOT FOUND THEN
          RETURN NEW;
        END IF;
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


CREATE FUNCTION outgoing_group_sms_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, sms_id)
             VALUES (NEW.group_id, NEW.sender_id, 'sms_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER outgoing_group_sms_event_trigger AFTER INSERT ON outgoing_group_sms_messages
    FOR EACH ROW EXECUTE PROCEDURE outgoing_group_sms_event_trigger();;

CREATE FUNCTION get_private_message_event_parent(private_messages) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id IS NULL THEN
            RETURN null;
        END IF;
        SELECT INTO id coalesce(evt.parent_id, evt.id) FROM events evt WHERE evt.private_message_id = obj.thread_id
;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
      pid int8 := NULL;
    BEGIN
      pid := get_private_message_event_parent(NEW);
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id)
             RETURNING * INTO evt;
      UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER private_message_event_trigger AFTER INSERT ON private_messages
    FOR EACH ROW EXECUTE PROCEDURE private_message_event_trigger();;

/* Table for storing invitations to a group */
CREATE TABLE group_invitations (
       created timestamp not null default (now() at time zone 'UTC'),
       email varchar(320) default null,
       user_id int8 references users(id) on delete cascade default null,
       group_id int8 not null references groups(id) on delete cascade,
       author_id int8 not null references users(id) on delete cascade,
       hash varchar(32) not null unique,
       facebook_id int8 default null,
       active boolean default true,
       primary key (hash),
       unique(group_id, email, active));;

create index group_invitations_user_id_idx on group_invitations(user_id);
create index group_invitations_group_id_idx on group_invitations(group_id);
create index group_invitations_author_id_idx on group_invitations(author_id);

/* Table for storing requests to join a group */
CREATE TABLE group_requests (
       created timestamp not null default (now() at time zone 'UTC'),
       user_id int8 references users(id) on delete cascade default null,
       group_id int8 not null references groups(id) on delete cascade,
       hash char(8) not null unique,
       primary key (hash));;

create index group_requests_user_id_idx on group_requests(user_id);
create index group_requests_group_id_idx on group_requests(group_id);

/* payments */
create table payments (
       id bigserial not null,
       group_id int8 default null references groups(id),
       user_id int8 default null references users(id) on delete set null,
       payment_type varchar(30),
       amount int8 default 0,
       valid bool default False,
       processed bool default False,
       created timestamp not null default (now() at time zone 'UTC'),
       referrer text,
       query_string text,

       raw_orderid varchar(250),
       raw_lang varchar(250),
       raw_amount varchar(250),
       raw_currency varchar(250),
       raw_paytext varchar(250),
       raw__ss2 varchar(250),
       raw__ss1 varchar(250),
       raw_name varchar(250),
       raw_surename varchar(250),
       raw_status varchar(250),
       raw_error varchar(250),
       raw_test varchar(250),
       raw_projectid varchar(250),
       raw_p_email varchar(250),
       raw_payamount varchar(250),
       raw_paycurrency varchar(250),
       raw_version varchar(250),

       primary key (id));;

/* tag search */
CREATE TABLE tag_search_items (
       tag_id int8 NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
       terms tsvector,
       PRIMARY KEY (tag_id));;

CREATE index tag_search_idx ON tag_search_items USING gin(terms);;

CREATE OR REPLACE FUNCTION make_vector(attrs text[]) RETURNS tsvector AS $$
    DECLARE
      str text := NULL;
      vector tsvector := NULL;
    BEGIN
      SELECT coalesce(array_to_string($1, ' '), '') INTO str;
      SELECT to_tsvector(str) INTO vector;
      RETURN vector;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION tag_indexable_content(int8) RETURNS tsvector AS $$
    DECLARE
        tag_id ALIAS FOR $1;
        tag tags;
        vector tsvector := NULL;
    BEGIN
        SELECT * FROM tags INTO tag WHERE id = tag_id AND tag_type = 'location';
        IF FOUND AND NOT tag_id IS NULL THEN
          SELECT make_vector(ARRAY[tag.title, tag.title_short, tag.description, tag.site_url]) INTO vector;
          RETURN vector;
        ELSE
          RETURN to_tsvector('');
        END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_tag_worker(tags) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        tag ALIAS FOR $1;
        vector tsvector := NULL;
    BEGIN
      IF tag.tag_type = 'location' THEN /* index only location tags */
          SELECT INTO vector tag_indexable_content(tags.id) || tag_indexable_content(tags.parent_id) FROM tags WHERE id = tag.id;
          SELECT tag_id INTO search_id FROM tag_search_items WHERE tag_id = tag.id;

          IF FOUND THEN
            UPDATE tag_search_items SET terms = vector
              WHERE tag_id=search_id;
          ELSE
            INSERT INTO tag_search_items (tag_id, terms) VALUES (tag.id, vector);
          END IF;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_tag_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_tag_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_tag_search AFTER INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE update_tag_search();;

/* subject ratings */
CREATE OR REPLACE FUNCTION update_page_location() RETURNS trigger AS $$
    BEGIN
      IF NEW.content_type <> 'subject' OR NEW.location_id = OLD.location_id THEN
        RETURN NEW;
      END IF;
      UPDATE content_items SET location_id = NEW.location_id
             FROM subject_pages s
             WHERE s.page_id = id
             AND s.subject_id = NEW.id;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION subject_rating_worker(content_items) RETURNS void AS $$
  DECLARE
      page_count int := 0;
      file_count int := 0;
      group_count int := 0;
      user_count int := 0;
      subject ALIAS FOR $1;
  BEGIN
    IF subject.content_type = 'subject' THEN
      SELECT COUNT(id) INTO page_count FROM subject_pages sp
        INNER JOIN content_items pg ON pg.id = sp.page_id
        WHERE sp.subject_id = subject.id
          AND pg.deleted_on IS NULL;
      SELECT COUNT(f.id) INTO file_count FROM files f
        INNER JOIN content_items fi ON fi.id = f.id
          WHERE f.parent_id = subject.id
          AND fi.deleted_on IS NULL;
      SELECT COUNT(group_id) INTO group_count FROM group_watched_subjects
        WHERE subject_id = subject.id;
      SELECT COUNT(user_id) INTO user_count FROM user_monitored_subjects
        WHERE ignored = false and subject_id = subject.id;
      UPDATE search_items SET rating = page_count + file_count + group_count + user_count
        WHERE content_item_id = subject.id;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_watches() RETURNS trigger as $$
  DECLARE
    subject content_items;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT * FROM content_items INTO subject WHERE id = OLD.subject_id AND content_type = 'subject';
    ELSE
        SELECT * FROM content_items INTO subject WHERE id = NEW.subject_id AND content_type = 'subject';
    END IF;
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_pages() RETURNS trigger as $$
  <<func>> DECLARE
    subject content_items;
    id int8 := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        id = OLD.id;
    ELSE
        id = NEW.id;
    END IF;
    SELECT parent.* FROM content_items parent INTO subject
        INNER JOIN subject_pages sp on sp.subject_id = parent.id
        WHERE sp.page_id = func.id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_files() RETURNS trigger as $$
  <<func>> DECLARE
    subject content_items;
    id int8 := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        id = OLD.id;
    ELSE
        id = NEW.id;
    END IF;
    SELECT parent.* FROM content_items parent INTO subject
        INNER JOIN files f on f.parent_id = parent.id
        WHERE f.id = func.id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_content_items() RETURNS trigger as $$
  <<func>> DECLARE
    val content_items;
    subject content_items;
    id int8 := NULL;
    content_type varchar(20) := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        val := OLD;
        id := OLD.id;
        content_type := OLD.content_type;
    ELSE
        val := NEW;
        id := NEW.id;
        content_type := NEW.content_type;
    END IF;

    IF content_type = 'subject' THEN
        RETURN val;
    END IF;

    IF content_type = 'file' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN files f on f.parent_id = parent.id
          WHERE f.id = func.id AND parent.content_type = 'subject';
        IF FOUND THEN
          PERFORM subject_rating_worker(subject);
         END IF;
    ELSIF content_type = 'page' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN subject_pages sp on sp.subject_id = parent.id
          WHERE sp.page_id = func.id AND parent.content_type = 'subject';
        IF FOUND THEN
            PERFORM subject_rating_worker(subject);
        END IF;
    END IF;


    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER update_subject_count_user AFTER INSERT OR UPDATE OR DELETE ON user_monitored_subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_watches();;

CREATE TRIGGER update_subject_count_group AFTER INSERT OR UPDATE OR DELETE ON group_watched_subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_watches();;

CREATE TRIGGER update_subject_count_files AFTER INSERT OR UPDATE OR DELETE ON files
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_files();;

CREATE TRIGGER update_subject_count_pages AFTER INSERT OR UPDATE OR DELETE ON pages
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_pages();;

CREATE TRIGGER update_subject_count_content_items AFTER INSERT OR UPDATE OR DELETE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_content_items();;

/* notification */
CREATE TABLE notifications (
       id bigserial NOT NULL,
       content text,
       valid_until date NOT NULL,
       primary key (id));;

/* notification - user relationship*/

CREATE TABLE notifications_viewed (
       user_id int8 NOT NULL REFERENCES users(id) on delete cascade,
       notification_id int8 NOT NULL REFERENCES notifications(id)
);;


/* a table for linking subjects with teachers */
create table teacher_taught_subjects (
       teacher_id int8 references teachers(id) on delete cascade not null,
       subject_id int8 not null references subjects(id) on delete cascade,
       primary key (teacher_id, subject_id));;

/* a table for linking teachers with their groups: ututi groups and other */
create table teacher_groups (
       id bigserial NOT NULL,
       teacher_id int8 references teachers(id) on delete cascade not null,
       title varchar(500) not null,
       email varchar(320) not null,
       group_id int8 default null references groups(id) on delete cascade,
       primary key (id));;

/* a table for storing user registration data */
CREATE TABLE user_registrations (
       id bigserial not null,
       created timestamp not null default (now() at time zone 'UTC'),
       hash varchar(32) not null unique,
       teacher boolean not null default false,
       email varchar(320) default null,
       email_confirmed boolean default false,
       fullname varchar(100) default null,
       password char(36) default null,
       logo bytea default null,
       openid varchar(200) default null,
       openid_email varchar(320) default null,
       facebook_id bigint default null,
       facebook_email varchar(320) default null,
       invited_emails text default null,  /* comma-separated emails */
       invited_fb_ids text default null,  /* comma-separated FB ids */
       inviter_id int8 default null references users(id) on delete set null,
       completed boolean default false,
       location_id int8 default null references tags(id) on delete cascade,
       university_title varchar(100) default null,
       university_country_id int8 default null references countries(id) on delete set null,
       university_site_url varchar(320) default null,
       university_logo bytea default null,
       university_member_policy university_member_policy default 'ALLOW_INVITES'::university_member_policy,
       university_allowed_domains text default null,
       user_id int8 default null references users(id) on delete set null,
       primary key (id));;

alter table user_registrations add constraint registration_data_integrity
    check ((location_id is null and email is not null) or
           (location_id is not null and (email is not null or facebook_id is not null)));;

/* A table for storing email domains.
 * Domain is considered public if location_id is NULL.
 */
create table email_domains (
       id bigserial not null,
       domain_name varchar(320) default null,
       location_id int8 default null references tags(id) on delete cascade,
       primary key (id),
       unique(domain_name));;

create index email_domains_domain_name_idx on email_domains(domain_name);


/* A table for storing wall posts.
 * Wall post type is determined by one of foreign keys being set.
 * Appropriate wall post events are created after inserts by
 * wall_post_event_trigger procedure.
 */
create table wall_posts (
       id int8 references content_items(id) on delete cascade,
       subject_id int8 references subjects(id) on delete cascade default null,
       target_location_id int8 default null, /* Should this reference a location? */
       content text not null,
       primary key (id),
       check(subject_id is not null or target_location_id is not null));

create or replace function wall_post_event_trigger() returns trigger as $$
    begin
        if new.subject_id is not null then
            insert into events(object_id, author_id, event_type)
                   values (new.id, cast(current_setting('ututi.active_user') as int8), 'subject_wall_post');
        elsif new.target_location_id is not null then
            insert into events(object_id, author_id, event_type)
                   values (new.id, cast(current_setting('ututi.active_user') as int8), 'location_wall_post');
        end if;
        return new;
    end
$$ language plpgsql;;

create trigger after_wall_post_event_trigger after insert or update on wall_posts
    for each row execute procedure wall_post_event_trigger();

/* A table for sub-departments

Universities and Departments are covered by location tag functionality.
*/
create table sub_departments (
       id bigserial not null,
       location_id int8 not null references tags(id) on delete cascade,
       slug varchar(150) default null,
       title varchar(500) not null,
       description text default null,
       unique(location_id, slug),
       primary key (id));;

alter table subjects add constraint subjects_sub_department_id_fkey
      foreign key (sub_department_id) references sub_departments(id)
      on delete set null;

/* A table for storing teacher blog posts.
 */
create table teacher_blog_posts (
       id int8 references content_items(id) on delete cascade,
       title varchar(250) not null,
       description text not null,
       primary key (id));;

create function teacher_blog_post_event_trigger() returns trigger as $$
    begin
        insert into events(object_id, author_id, event_type)
               values (new.id, cast(current_setting('ututi.active_user') as int8), 'teacher_blog_post');
        return new;
    end
$$ language plpgsql;;

/* Disable teacher blog post event generation until it's needed
create trigger teacher_blog_post_event_trigger after insert or update on teacher_blog_posts
    for each row execute procedure teacher_blog_post_event_trigger();
*/

create table teacher_blog_comments (
       id int8 references content_items(id) on delete cascade,
       post_id int8 references teacher_blog_posts(id) on delete cascade not null,
       content text not null,
       primary key (id));;
