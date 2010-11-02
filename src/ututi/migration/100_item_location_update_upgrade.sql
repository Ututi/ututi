CREATE OR REPLACE FUNCTION update_item_location() RETURNS trigger AS $$
    BEGIN
      IF (NEW.content_type <> 'subject' AND NEW.content_type <> 'group') OR NEW.location_id = OLD.location_id THEN
        RETURN NEW;
      END IF;
      UPDATE content_items SET location_id = NEW.location_id
             FROM subject_pages s
             WHERE s.page_id = id
             AND s.subject_id = NEW.id;
      UPDATE content_items ci set location_id = NEW.location_id
             FROM files f
             WHERE f.id = ci.id
             AND f.parent_id = NEW.id;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_item_location AFTER UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE update_item_location();;

DROP TRIGGER update_page_location ON content_items;;
