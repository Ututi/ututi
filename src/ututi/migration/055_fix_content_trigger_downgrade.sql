DROP TRIGGER IF EXISTS on_content_update ON content_items;
CREATE TRIGGER on_content_update AFTER UPDATE ON content_items
     FOR EACH ROW EXECUTE PROCEDURE on_content_update();;
