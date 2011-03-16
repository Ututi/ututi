CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
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

CREATE OR REPLACE FUNCTION temp_update(events) RETURNS void AS $$
    DECLARE
        pid int8 := NULL;
        evt ALIAS FOR $1;
        msg group_mailing_list_messages;
    BEGIN
        select * INTO msg from group_mailing_list_messages where id = evt.message_id;
        pid := get_group_mailing_list_message_event_parent(msg);
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
    END
$$ LANGUAGE plpgsql;;

SELECT temp_update(e.*) FROM events e WHERE e.event_type = 'mailinglist_post_created' ORDER by e.created ASC;;

CREATE OR REPLACE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      evt events;
      pid int8 := NULL;
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        pid := get_group_forum_post_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, post_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id)
               RETURNING * INTO evt;
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION temp_update(events) RETURNS void AS $$
    DECLARE
        pid int8 := NULL;
        evt ALIAS FOR $1;
        msg forum_posts;
    BEGIN
        SELECT * INTO msg FROM forum_posts where id = evt.post_id;
        pid := get_group_forum_post_event_parent(msg);
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
    END
$$ LANGUAGE plpgsql;;

SELECT temp_update(e.*) FROM events e WHERE e.event_type = 'forum_post_created' ORDER by e.created ASC;;

CREATE OR REPLACE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
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

CREATE OR REPLACE FUNCTION temp_update(events) RETURNS void AS $$
    DECLARE
        pid int8 := NULL;
        evt ALIAS FOR $1;
        msg private_messages;
    BEGIN
        select * into msg from private_messages where id = evt.private_message_id;
        pid := get_private_message_event_parent(msg);
        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
    END
$$ LANGUAGE plpgsql;;

SELECT temp_update(e.*) FROM events e WHERE e.event_type = 'private_message_sent' ORDER by e.created ASC;;

create index event_parent_is_null on events(created) where parent_id is null;;
