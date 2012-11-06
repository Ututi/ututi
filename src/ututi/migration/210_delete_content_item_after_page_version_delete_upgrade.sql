DELETE
from
    content_items
where
    content_type='page_version'
    and (select
            count(*)
         from page_versions
         where
            page_versions.id=content_items.id) = 0
;

DROP TRIGGER delete_content_item_after_group_delete ON group_mailing_list_messages;

DROP FUNCTION group_message_delete_content_item();

CREATE OR REPLACE FUNCTION delete_content_item() RETURNS trigger
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
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_page_version_delete
	AFTER DELETE ON page_versions
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();
