alter table events add column last_activity timestamp not null default (now() at time zone 'UTC');

CREATE OR REPLACE FUNCTION event_comment_created_trigger() RETURNS trigger AS $$
    BEGIN
        UPDATE events SET last_activity  = (now() at time zone 'UTC') WHERE id = NEW.event_id;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER after_event_comment_created AFTER INSERT ON event_comments
    FOR EACH ROW EXECUTE PROCEDURE event_comment_created_trigger();;
