alter table content_items alter column created_by drop not null;
alter table group_mailing_list_messages alter column author_id drop not null;

CREATE OR REPLACE FUNCTION on_content_create() RETURNS trigger AS $$
    BEGIN
      IF (current_setting('ututi.active_user') <> '') THEN
        NEW.created_by = current_setting('ututi.active_user');
      ELSE
        NEW.created_by = NULL;
      END IF;
      NEW.created_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

alter table events alter column author_id drop not null;

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'mailinglist_post_created', NEW.id);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;
