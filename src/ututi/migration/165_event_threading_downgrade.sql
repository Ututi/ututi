CREATE OR REPLACE FUNCTION get_group_forum_post_event_parent(forum_posts) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id = obj.id THEN
            RETURN NULL; /* This post is root of the thread. */
        END IF;
        SELECT INTO id evt.id FROM events evt INNER JOIN forum_posts msg
               ON msg.id = evt.post_id
               WHERE msg.id = obj.thread_id;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION get_private_message_event_parent(private_messages) RETURNS int8 AS $$
    DECLARE
        obj ALIAS FOR $1;
        id int8 := null;
    BEGIN
        IF obj.thread_id IS NULL THEN
            RETURN null;
        END IF;
        SELECT INTO id evt.id FROM events evt WHERE evt.private_message_id = obj.thread_id
;
        RETURN id;
    END
$$ LANGUAGE plpgsql;;

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
