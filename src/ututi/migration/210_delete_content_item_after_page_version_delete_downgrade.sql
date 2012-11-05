DROP TRIGGER delete_content_item_after_group_delete ON group_mailing_list_messages;

DROP TRIGGER delete_content_item_after_page_version_delete ON page_versions;

DROP FUNCTION delete_content_item();

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
