DROP TRIGGER group_mailing_list_message_event_trigger ON group_mailing_list_messages;

CREATE TRIGGER group_mailing_list_message_event_trigger
	AFTER INSERT OR UPDATE ON group_mailing_list_messages
	FOR EACH ROW
	EXECUTE PROCEDURE group_mailing_list_message_event_trigger();

DROP FUNCTION temp_update(events);

DROP FUNCTION temp_update(group_mailing_list_messages);

ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_pkey;

ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_recipient_uid_fkey;

ALTER TABLE sms_outbox
	DROP CONSTRAINT sms_sender_uid_fkey;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_pkey PRIMARY KEY (id);

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_recipient_uid_fkey FOREIGN KEY (recipient_uid) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE sms_outbox
	ADD CONSTRAINT sms_outbox_sender_uid_fkey FOREIGN KEY (sender_uid) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE group_mailing_list_messages
	DROP CONSTRAINT group_mailing_list_messages_author_id_fkey;

ALTER TABLE group_mailing_list_messages
	ADD CONSTRAINT group_mailing_list_messages_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE group_mailing_list_messages
	ALTER COLUMN thread_message_machine_id SET NOT NULL;

ALTER TABLE content_items
	DROP CONSTRAINT content_items_created_by_fkey;

ALTER TABLE content_items
	DROP CONSTRAINT content_items_modified_by_fkey;

ALTER TABLE content_items
	ADD CONSTRAINT content_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES authors(id) ON DELETE SET NULL;

ALTER TABLE content_items
	ADD CONSTRAINT content_items_modified_by_fkey FOREIGN KEY (modified_by) REFERENCES authors(id) ON DELETE SET NULL;

ALTER TABLE tags
	ADD CONSTRAINT tags_parent_id_key UNIQUE (parent_id, title);

update tags set teachers_url = '' where teachers_url is null;
ALTER TABLE tags
	ALTER COLUMN teachers_url SET DEFAULT ''::character varying,
	ALTER COLUMN teachers_url SET NOT NULL;

ALTER TABLE outgoing_group_sms_messages
	DROP CONSTRAINT outgoing_group_sms_messages_sender_id_fkey1;

ALTER TABLE outgoing_group_sms_messages
	ADD CONSTRAINT outgoing_group_sms_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE payments
	DROP CONSTRAINT payments_group_id_fkey;

ALTER TABLE payments
	DROP CONSTRAINT payments_user_id_fkey;

ALTER TABLE payments
	ADD CONSTRAINT payments_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE payments
	ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE received_sms_messages
	DROP CONSTRAINT received_sms_messages_sender_id_fkey1;

ALTER TABLE received_sms_messages
	ADD CONSTRAINT received_sms_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE teacher_taught_subjects
	DROP CONSTRAINT teacher_tought_subjects_subject_id_fkey;

ALTER TABLE teacher_taught_subjects
	ADD CONSTRAINT teacher_taught_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;

ALTER TABLE user_registrations
	ADD CONSTRAINT user_registrations_hash_key UNIQUE (hash);

ALTER TABLE i18n_texts_versions
	ALTER COLUMN i18n_texts_id DROP DEFAULT;

ALTER TABLE users
	DROP COLUMN fullname,
	DROP COLUMN has_voted,
	ALTER COLUMN id DROP DEFAULT;

DROP SEQUENCE i18n_texts_versions_i18n_texts_id_seq;

DROP SEQUENCE users_id_seq;

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

