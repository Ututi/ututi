DELETE
from
    content_items
where
    content_type='mailing_list_message'
    and (select
            count(*)
         from group_mailing_list_messages
         where
            group_mailing_list_messages.id=content_items.id) = 0
;

CREATE OR REPLACE FUNCTION group_message_delete_content_item() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
        delete from content_items where content_items.id=OLD.id;
        RETURN NULL;
    end;
$$;

CREATE TRIGGER delete_content_item_after_group_delete
	AFTER DELETE ON group_mailing_list_messages
	FOR EACH ROW
	EXECUTE PROCEDURE group_message_delete_content_item();
