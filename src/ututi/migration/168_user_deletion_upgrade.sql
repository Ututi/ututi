UPDATE users
       SET location_id = location_ids.location_id
 FROM (SELECT u.id AS user_id, min(ci.location_id) AS location_id
        FROM users u INNER JOIN group_members gm ON u.id = gm.user_id
        LEFT JOIN content_items ci ON ci.id = gm.group_id
        WHERE u.location_id IS NULL GROUP BY u.id) AS location_ids
 WHERE users.id = location_ids.user_id;

ALTER TABLE ONLY public.emails DROP CONSTRAINT emails_id_fkey;
ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_id_fkey FOREIGN KEY (id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.events DROP CONSTRAINT events_author_id_fkey;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.events DROP CONSTRAINT events_recipient_id_fkey;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.file_downloads DROP CONSTRAINT file_downloads_user_id_fkey;
ALTER TABLE ONLY public.file_downloads
    ADD CONSTRAINT file_downloads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.group_invitations DROP CONSTRAINT group_invitations_user_id_fkey;
ALTER TABLE ONLY public.group_invitations
    ADD CONSTRAINT group_invitations_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.group_invitations DROP CONSTRAINT group_invitations_author_id_fkey;
ALTER TABLE ONLY public.group_invitations
    ADD CONSTRAINT group_invitations_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.group_mailing_list_messages DROP CONSTRAINT group_mailing_list_messages_author_id_fkey;
ALTER TABLE ONLY public.group_mailing_list_messages
    ADD CONSTRAINT group_mailing_list_messages_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.group_members DROP CONSTRAINT group_members_user_id_fkey;
ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.notifications_viewed DROP CONSTRAINT notifications_viewed_user_id_fkey;
ALTER TABLE ONLY public.notifications_viewed
    ADD CONSTRAINT notifications_viewed_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.private_messages DROP CONSTRAINT private_messages_sender_id_fkey;
ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.private_messages DROP CONSTRAINT private_messages_recipient_id_fkey;
ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.seen_threads DROP CONSTRAINT seen_threads_user_id_fkey;
ALTER TABLE ONLY public.seen_threads
    ADD CONSTRAINT seen_threads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.user_monitored_subjects DROP CONSTRAINT user_monitored_subjects_user_id_fkey;
ALTER TABLE ONLY public.user_monitored_subjects
    ADD CONSTRAINT user_monitored_subjects_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.subscribed_threads DROP CONSTRAINT subscribed_threads_user_id_fkey;
ALTER TABLE ONLY public.subscribed_threads
    ADD CONSTRAINT subscribed_threads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.page_versions DROP CONSTRAINT page_versions_id_fkey;
ALTER TABLE ONLY public.page_versions
    ADD CONSTRAINT page_versions_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.pages DROP CONSTRAINT pages_id_fkey;
ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.groups DROP CONSTRAINT groups_id_fkey;
ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.books DROP CONSTRAINT books_id_fkey;
ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.subjects DROP CONSTRAINT subjects_id_fkey;
ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.files DROP CONSTRAINT files_id_fkey;
ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.forum_posts DROP CONSTRAINT forum_posts_id_fkey;
ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.private_messages DROP CONSTRAINT private_messages_id_fkey;
ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.event_comments DROP CONSTRAINT event_comments_id_fkey;
ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_id_fkey FOREIGN KEY (id) REFERENCES content_items(id)  ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION member_group_event_trigger() RETURNS trigger AS $$
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

ALTER TABLE ONLY public.group_requests DROP CONSTRAINT group_requests_user_id_fkey;
ALTER TABLE ONLY public.group_requests
    ADD CONSTRAINT group_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.user_medals DROP CONSTRAINT user_medals_user_id_fkey;
ALTER TABLE ONLY public.user_medals
    ADD CONSTRAINT user_medals_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.coupon_usage DROP CONSTRAINT coupon_usage_user_id_fkey;
ALTER TABLE ONLY public.coupon_usage
    ADD CONSTRAINT coupon_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_user_id_fkey;
ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE;

DROP TRIGGER group_mailing_list_message_event_trigger ON group_mailing_list_messages;
CREATE TRIGGER group_mailing_list_message_event_trigger AFTER INSERT ON group_mailing_list_messages
    FOR EACH ROW EXECUTE PROCEDURE group_mailing_list_message_event_trigger();;

CREATE OR REPLACE FUNCTION group_subject_event_trigger() RETURNS trigger AS $$
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
