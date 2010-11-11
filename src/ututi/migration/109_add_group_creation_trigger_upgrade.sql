CREATE FUNCTION group_creation_event_trigger() RETURNS trigger AS $$
    BEGIN
      EXECUTE add_event(NEW.id, cast('group_created' as varchar));
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER group_created_event_trigger BEFORE INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE group_creation_event_trigger();;
