UPDATE content_items cc
       SET location_id = (SELECT c.location_id FROM content_items c INNER JOIN files f ON c.id = f.parent_id WHERE f.id = cc.id) 
       WHERE cc.content_type = 'file';

CREATE OR REPLACE FUNCTION set_file_location() RETURNS trigger AS $$
    DECLARE
        parent_location_id int8 := NULL;
    BEGIN
      SELECT location_id INTO parent_location_id FROM content_items WHERE id = NEW.parent_id;
      UPDATE content_items SET location_id = parent_location_id WHERE id = NEW.id;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER set_file_location AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE set_file_location();;
