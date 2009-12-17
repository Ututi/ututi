CREATE OR REPLACE FUNCTION set_deleted_on() RETURNS trigger AS $$
    BEGIN
        IF not NEW.deleted_by is NULL AND OLD.deleted_by is NULL THEN
          NEW.deleted_on := (now() at time zone 'UTC');
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_deleted_on BEFORE UPDATE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE set_deleted_on();

UPDATE content_items SET deleted_on = (now() at time zone 'UTC') WHERE NOT deleted_by IS NULL;
