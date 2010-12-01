
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
       openid varchar(200) default null unique,
       facebook_id bigint default null unique,
       phone_number varchar(20) default null,
       phone_confirmed boolean default false,
       phone_confirmation_key char(32) default '',
       sms_messages_remaining int8 default 30,
       profile_is_public boolean default true,
       hidden_blocks text default '',
       last_seen_feed timestamp not null default (now() at time zone 'UTC'),
       location_country varchar(5) default null,
       location_city varchar(30) default null,
       ignored_events text default '',
       user_type varchar(10) not null default 'user',
       teacher_verified boolean default null,
       teacher_position varchar(200) default null,
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

/* user medals */
create table user_medals (
       id bigserial not null,
       user_id int8 default null references users(id),
       medal_type varchar(30) not null,
       awarded_on timestamp not null default (now() at time zone 'UTC'),
       primary key (id),
       unique(user_id, medal_type));;

create index user_medals_user_id on user_medals(user_id);

insert into user_medals (user_id, medal_type) values (1, 'admin2');

/* A generic table for Ututi objects */
create table content_items (id bigserial not null,
       content_type varchar(20) not null default '',
       created_by int8 references users(id),
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
        ELSIF NEW.deleted_by is NULL AND NOT OLD.deleted_by is NULL THEN
          NEW.deleted_on := NULL;
        END IF;

        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_deleted_on BEFORE UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE set_deleted_on();;

/* private messages */
CREATE TABLE private_messages (id int8 references content_items(id),
       sender_id int8 not null references users(id),
       recipient_id int8 not null references users(id),
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

create index files_parent_id_idx on files(parent_id);
create index md5 on files (md5);;

create table file_downloads (file_id int8 references files(id) on delete cascade,
       user_id int8 references users(id),
       download_time timestamp not null default (now() at time zone 'UTC'),
       range_start int8 default null,
       range_end int8 default null,
       primary key(file_id, user_id, download_time));;

create index file_downloads_user_id_idx on file_downloads(user_id);

create index user_id on file_downloads (user_id);;
create index file_id on file_downloads (file_id);;

/* A table for regions */
create table regions (id bigserial not null,
       title varchar(250) not null,
       country varchar(2) not null,
       primary key (id));;

/* A table for tags (location and simple tags) */
create table tags (id bigserial not null,
       title varchar(250) not null,
       title_short varchar(50) default null,
       description text default null,
       logo bytea default null,
       tag_type varchar(10) default null,
       site_url varchar(200) default null,
       confirmed bool default true,
       region_id int8 default null references regions(id) on delete restrict,
       parent_id int8 default null references tags(id) on delete cascade,
       primary key (id),
       unique(parent_id, title));;

CREATE FUNCTION tag_title_lowercase() RETURNS trigger AS $tag_parent$
    BEGIN
        NEW.title_short = LOWER(NEW.title_short);
        RETURN NEW;
    END
$tag_parent$ LANGUAGE plpgsql;;

CREATE TRIGGER tag_title_lowercase BEFORE INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE tag_title_lowercase();;

create unique index parent_title_unique_idx on tags(coalesce(parent_id, 0), title_short);;

alter table users add column location_id int8 default null references tags(id) on delete set null;;

insert into tags (title, title_short, description, tag_type)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.', 'location');;
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('Ekonomikos fakultetas', 'ef', '', 1, 'location');;

/* Add location field to the content item table */
alter table content_items add column location_id int8 default null references tags(id) on delete set null;;

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
       id int8 references content_items(id),
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
       mailinglist_moderated bool not null default false,
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
       user_id int8 not null references users(id),
       primary key (coupon_id, user_id));;

/* An enumerator for membership types in groups */
create table group_membership_types (
       membership_type varchar(20) not null,
       primary key (membership_type));;


/* A table that tracks user membership in groups */
create table group_members (
       group_id int8 references groups(id) on delete cascade not null,
       user_id int8 references users(id) not null,
       membership_type varchar(20) not null references group_membership_types(membership_type) on delete cascade,
       subscribed bool default true,
       receive_email_each varchar(30) default 'day',
       subscribed_to_forum bool default false,
       primary key (group_id, user_id));;

create index group_members_group_id_idx on group_members(group_id);
create index group_members_user_id_idx on group_members(user_id);

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
       subject_id int8 not null references subjects(id) on delete cascade,
       ignored bool default false,
       primary key (user_id, subject_id, ignored));;

/* A table for pages */

create table pages (
       id int8 not null references content_items(id),
       primary key(id));;

create table page_versions(id int8 not null references content_items(id),
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
       thread_message_id varchar(320) not null,
       thread_group_id int8 references groups(id) on delete cascade not null,
       author_id int8 references users(id),
       subject varchar(500) not null,
       original bytea not null,
       sent timestamp not null,
       in_moderation_queue boolean default false,
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

INSERT INTO forum_categories (group_id, title, description)
    VALUES (NULL, 'Community', 'Ututi community forum');
INSERT INTO forum_categories (group_id, title, description)
    VALUES (NULL, 'Report a bug', 'Report bugs here' );


CREATE TABLE forum_posts (
       id int8 not null references content_items(id),
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
       user_id int8 not null references users(id),
       visited_on timestamp not null default '2000-01-01',
       primary key(thread_id, user_id));;

CREATE TABLE subscribed_threads (
       thread_id int8 not null references forum_posts on delete cascade,
       user_id int8 not null references users(id),
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
create table content_tags (id bigserial not null,
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
      IF CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
        NEW.modified_by = current_setting('ututi.active_user');
        NEW.modified_on = (now() at time zone 'UTC');
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
       author_id int8 references users(id),
       recipient_id int8 default null references users(id),
       created timestamp not null default (now() at time zone 'UTC'),
       event_type varchar(30),
       file_id int8 references files(id) on delete cascade default null,
       page_id int8 references pages(id) on delete cascade default null,
       subject_id int8 references subjects(id) on delete cascade default null,
       message_id int8 references group_mailing_list_messages(id) on delete cascade default null,
       post_id int8 references forum_posts(id) on delete cascade default null,
       sms_id int8 references outgoing_group_sms_messages(id) on delete cascade default null,
       private_message_id int8 references private_messages(id) on delete cascade default null,
       primary key (id));;

create index events_author_id_idx on events(author_id);

CREATE FUNCTION add_event(event_id int8, evtype varchar) RETURNS void AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype);
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION set_ci_modtime(content_item_id int8) RETURNS void AS $$
    BEGIN
      IF CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
        UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
          modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
      END IF;
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

CREATE FUNCTION group_creation_event_trigger() RETURNS trigger AS $$
    BEGIN
      EXECUTE add_event(NEW.id, cast('group_created' as varchar));
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_created_event_trigger BEFORE INSERT ON groups
    FOR EACH ROW EXECUTE PROCEDURE group_creation_event_trigger();;

CREATE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER group_mailing_list_message_event_trigger AFTER INSERT OR UPDATE ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE group_mailing_list_message_event_trigger();;


CREATE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        INSERT INTO events (object_id, author_id, event_type, post_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_forum_message_event_trigger AFTER INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE group_forum_message_event_trigger();;


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


CREATE FUNCTION outgoing_group_sms_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, sms_id)
             VALUES (NEW.group_id, NEW.sender_id, 'sms_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER outgoing_group_sms_event_trigger AFTER INSERT ON outgoing_group_sms_messages
    FOR EACH ROW EXECUTE PROCEDURE outgoing_group_sms_event_trigger();;


CREATE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER private_message_event_trigger AFTER INSERT ON private_messages
    FOR EACH ROW EXECUTE PROCEDURE private_message_event_trigger();;

/* Table for storing invitations to a group */
CREATE TABLE group_invitations (
       created timestamp not null default (now() at time zone 'UTC'),
       email varchar(320) default null,
       user_id int8 references users(id) default null,
       group_id int8 not null references groups(id) on delete cascade,
       author_id int8 not null references users(id),
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
       user_id int8 references users(id) default null,
       group_id int8 not null references groups(id) on delete cascade,
       hash char(8) not null unique,
       primary key (hash));;

create index group_requests_user_id_idx on group_requests(user_id);
create index group_requests_group_id_idx on group_requests(group_id);

/* blog entries */
create table blog (
       id bigserial not null,
       content text not null default '',
       created date not null default (now() at time zone 'UTC'),
       primary key (id));;


/* payments */
create table payments (
       id bigserial not null,
       group_id int8 default null references groups(id),
       user_id int8 default null references users(id),
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
      SELECT INTO vector tag_indexable_content(tags.id) || tag_indexable_content(tags.parent_id) FROM tags WHERE id = tag.id;
      SELECT tag_id INTO search_id FROM tag_search_items WHERE tag_id = tag.id;

      IF FOUND and tag.tag_type = 'location' THEN
        UPDATE tag_search_items SET terms = vector
          WHERE tag_id=search_id;
      ELSE
        INSERT INTO tag_search_items (tag_id, terms) VALUES (tag.id, vector);
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
  DECLARE
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
        WHERE sp.page_id = id AND parent.content_type = 'subject';
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
  DECLARE
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
        WHERE f.id = id AND parent.content_type = 'subject';
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
  DECLARE
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
          WHERE f.id = id AND parent.content_type = 'subject';
        IF FOUND THEN
          PERFORM subject_rating_worker(subject);
         END IF;
    ELSIF content_type = 'page' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN subject_pages sp on sp.subject_id = parent.id
          WHERE sp.page_id = id AND parent.content_type = 'subject';
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
       user_id int8 NOT NULL REFERENCES users(id),
       notification_id int8 NOT NULL REFERENCES notifications(id)
);;


/* Books */

create table school_grades (
       id bigserial not null,
       name varchar(20) not null,
       primary key (id));;


create table cities (
       id bigserial not null,
       name varchar(100) not null,
       priority int8 NOT NULL DEFAULT 0,
       primary key (id)
);;

CREATE TABLE science_types (
       id bigserial NOT NULL,
       name varchar(100) NOT NULL,
       book_department_id int8 NOT NULL, -- actualy an enum
       PRIMARY KEY (id)
);;

create table book_types (
       id bigserial not null,
       name varchar(100) not null,
       primary key (id)
);;

CREATE TABLE books (
       id bigserial NOT NULL,
       title varchar(100) NOT NULL,
       description text,
       author varchar(100),
       price varchar(250) DEFAULT '' NOT NULL,
       logo bytea DEFAULT NULL,
       owner_id int8 NOT NULL REFERENCES users(id) on delete cascade,
       city_id int8 DEFAULT NULL REFERENCES cities(id) on delete restrict,
       science_type_id int8 NOT NULL REFERENCES science_types(id) on delete restrict,
       type_id int8 NOT NULL REFERENCES book_types(id) on delete restrict,
       department_id int8 NOT NULL,
       school_grade_id int8 REFERENCES school_grades(id) on delete restrict,
       course varchar(100) default '',
       location_id int8 REFERENCES tags(id),
       owner_name varchar(50) not null,
       owner_phone varchar(50) not null,
       owner_email varchar(100) not null,
       valid_until timestamp not null default (now() at time zone 'UTC'),
       PRIMARY KEY (id)
);;

/* a table for linking subjects with teachers */
create table teacher_tought_subjects (
       user_id int8 references users(id) not null,
       subject_id int8 not null references subjects(id) on delete cascade,
       primary key (user_id, subject_id));;
