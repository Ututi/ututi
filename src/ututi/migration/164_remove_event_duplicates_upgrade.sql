delete from events where event_type in ('mailinglist_post_created', 'moderated_post_created');

CREATE OR REPLACE FUNCTION temp_update(group_mailing_list_messages) RETURNS void AS $$
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
$$ LANGUAGE plpgsql;;

select temp_update(ml.*) from group_mailing_list_messages ml inner join content_items c on c.id = ml.id order by c.created_on asc;
