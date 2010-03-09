update content_items set deleted_on = null where deleted_by is null and deleted_on is not null;

CREATE OR REPLACE FUNCTION set_deleted_on() RETURNS trigger AS $$
    BEGIN
        IF not NEW.deleted_by is NULL AND OLD.deleted_by is NULL THEN
          NEW.deleted_on := (now() at time zone 'UTC');
        ELSIF NEW.deleted_by is NULL AND NOT OLD.deleted_by is NULL THEN
          NEW.deleted_on := NULL;
        END IF;

        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

