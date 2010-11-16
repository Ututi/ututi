alter table content_items alter column created_by set not null;
alter table group_mailing_list_messages alter column author_id set not null;

CREATE OR REPLACE FUNCTION on_content_create() RETURNS trigger AS $$
    BEGIN
      NEW.created_by = current_setting('ututi.active_user');
      NEW.created_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

alter table events alter column author_id set not null;

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type, message_id)
             VALUES (NEW.group_id, cast(current_setting('ututi.active_user') as int8), 'mailinglist_post_created', NEW.id);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;
