DROP TRIGGER group_mailing_list_message_event_trigger ON group_mailing_list_messages;

CREATE TRIGGER group_mailing_list_message_event_trigger
	AFTER INSERT ON group_mailing_list_messages
	FOR EACH ROW
	EXECUTE PROCEDURE group_mailing_list_message_event_trigger();

CREATE OR REPLACE FUNCTION temp_update(events) RETURNS void
    LANGUAGE plpgsql
    AS $_$
    DECLARE
        pid int8 := NULL;
        evt ALIAS FOR $1;
        msg private_messages;
    BEGIN
        select * into msg from private_messages where id = evt.private_message_id;
        pid := get_private_message_event_parent(msg);
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
    END
$_$;

CREATE OR REPLACE FUNCTION temp_update(group_mailing_list_messages) RETURNS void
    LANGUAGE plpgsql
    AS $_$
    DECLARE
        pid int8 := NULL;
        ml ALIAS FOR $1;
        c content_items;
        evt events;
        msg group_mailing_list_messages;
    BEGIN
      select INTO c * from content_items where id = ml.id;
      IF ml.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id, created)
               VALUES (ml.group_id, ml.author_id, 'moderated_post_created', ml.id, c.created_on);
      ELSE
        INSERT INTO events (object_id, author_id, event_type, message_id, created)
               VALUES (ml.group_id, ml.author_id, 'mailinglist_post_created', ml.id, c.created_on)
               RETURNING * INTO evt;
        UPDATE events SET parent_id = evt.id WHERE message_id != ml.id and message_id in (select id from group_mailing_list_messages where thread_message_machine_id = ml.thread_message_machine_id);
      END IF;
    END
$_$;


ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_outbox_pkey;

ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_outbox_recipient_uid_fkey;

ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_outbox_sender_uid_fkey;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_pkey PRIMARY KEY (id);

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_recipient_uid_fkey FOREIGN KEY (recipient_uid) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_sender_uid_fkey FOREIGN KEY (sender_uid) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE group_mailing_list_messages
	DROP CONSTRAINT group_mailing_list_messages_author_id_fkey;

ALTER TABLE group_mailing_list_messages
	ADD CONSTRAINT group_mailing_list_messages_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE group_mailing_list_messages
	ALTER COLUMN thread_message_machine_id DROP NOT NULL;

ALTER TABLE content_items
	DROP CONSTRAINT content_items_created_by_fkey;

ALTER TABLE content_items
	DROP CONSTRAINT content_items_modified_by_fkey;

ALTER TABLE content_items
	ADD CONSTRAINT content_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES authors(id) ON DELETE CASCADE;

ALTER TABLE content_items
	ADD CONSTRAINT content_items_modified_by_fkey FOREIGN KEY (modified_by) REFERENCES authors(id) ON DELETE CASCADE;

ALTER TABLE tags
	DROP CONSTRAINT tags_parent_id_key;

ALTER TABLE tags
	ALTER COLUMN teachers_url DROP DEFAULT,
	ALTER COLUMN teachers_url DROP NOT NULL;

ALTER TABLE outgoing_group_sms_messages
	DROP CONSTRAINT outgoing_group_sms_messages_sender_id_fkey;

ALTER TABLE outgoing_group_sms_messages
	ADD CONSTRAINT outgoing_group_sms_messages_sender_id_fkey1 FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE payments
	DROP CONSTRAINT payments_group_id_fkey;

ALTER TABLE payments
	DROP CONSTRAINT payments_user_id_fkey;

ALTER TABLE payments
	ADD CONSTRAINT payments_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;

ALTER TABLE payments
	ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE received_sms_messages
	DROP CONSTRAINT received_sms_messages_sender_id_fkey;

ALTER TABLE received_sms_messages
	ADD CONSTRAINT received_sms_messages_sender_id_fkey1 FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE teacher_taught_subjects
	DROP CONSTRAINT teacher_taught_subjects_subject_id_fkey;

ALTER TABLE teacher_taught_subjects
	ADD CONSTRAINT teacher_tought_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;

ALTER TABLE user_registrations
	DROP CONSTRAINT user_registrations_hash_key;

CREATE SEQUENCE i18n_texts_versions_i18n_texts_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

SELECT setval('i18n_texts_versions_i18n_texts_id_seq', (SELECT COALESCE(MAX(i18n_texts_id), 0) + 1 FROM i18n_texts_versions), false);

ALTER TABLE i18n_texts_versions
	ALTER COLUMN i18n_texts_id SET DEFAULT nextval('i18n_texts_versions_i18n_texts_id_seq'::regclass);


CREATE SEQUENCE users_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

SELECT setval('users_id_seq', (SELECT COALESCE(MAX(id), 0) + 1 FROM users), false);

ALTER TABLE users
	ADD COLUMN fullname character varying(100),
	ADD COLUMN has_voted boolean DEFAULT false,
	ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);

CREATE OR REPLACE FUNCTION on_content_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (current_setting('ututi.active_user') <> '') THEN
       IF CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
              NEW.modified_by = current_setting('ututi.active_user');
              NEW.modified_on = (now() at time zone 'UTC');
       END IF;
  END IF;
  RETURN NEW;
END
$$;


CREATE OR REPLACE FUNCTION set_ci_modtime(content_item_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (current_setting('ututi.active_user') <> '') AND
        CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
        UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
               modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
    END IF;
END
$$;


CREATE OR REPLACE FUNCTION update_tag_worker(tags) RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
 $_$;

