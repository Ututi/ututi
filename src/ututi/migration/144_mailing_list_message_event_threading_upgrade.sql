CREATE OR REPLACE FUNCTION get_group_mailing_list_message_event_parent(group_mailing_list_messages) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_message_id = obj.message_id AND obj.thread_group_id = obj.group_id THEN
            RETURN NULL; /* This message is root of the thread. */
        END IF;
        SELECT INTO id evt.id FROM events evt INNER JOIN group_mailing_list_messages msg
               ON msg.id = evt.message_id
               WHERE msg.message_id = obj.thread_message_id AND msg.group_id = obj.thread_group_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        pid := get_group_mailing_list_message_event_parent();
        INSERT INTO events (object_id, author_id, event_type, message_id, parent_id)
               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id, pid);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_group_mailing_list_message_event_parent(msg.*)
      FROM group_mailing_list_messages msg
      WHERE msg.id = events.message_id)
  WHERE events.event_type = 'mailinglist_post_created';
