CREATE OR REPLACE FUNCTION check_gadugadu() RETURNS trigger AS $$
    BEGIN
        IF NEW.gadugadu_uin is NULL THEN
          NEW.gadugadu_confirmed := false;
          NEW.gadugadu_confirmation_key := '';
          NEW.gadugadu_get_news := false;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;


CREATE TRIGGER check_gadugadu BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE check_gadugadu();;
