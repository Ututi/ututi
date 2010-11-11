DROP TRIGGER group_created_event_trigger ON groups;

CREATE TRIGGER group_created_event_trigger BEFORE INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE group_creation_event_trigger();;
