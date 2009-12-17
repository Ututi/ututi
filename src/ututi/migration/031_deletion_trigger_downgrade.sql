DROP TRIGGER set_deleted_on ON content_items;
UPDATE content_items SET deleted_on = NULL WHERE NOT deleted_by IS NULL;
