ALTER TABLE users
	ADD COLUMN gadugadu_uin bigint,
	ADD COLUMN gadugadu_confirmed boolean DEFAULT false,
	ADD COLUMN gadugadu_confirmation_key character(32) DEFAULT ''::bpchar,
	ADD COLUMN gadugadu_get_news boolean DEFAULT false;

CREATE OR REPLACE FUNCTION check_gadugadu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF NEW.gadugadu_uin is NULL THEN
          NEW.gadugadu_confirmed := false;
          NEW.gadugadu_confirmation_key := '';
          NEW.gadugadu_get_news := false;
        END IF;
        RETURN NEW;
    END
$$;


CREATE TRIGGER check_gadugadu
	BEFORE INSERT OR UPDATE ON users
	FOR EACH ROW
	EXECUTE PROCEDURE check_gadugadu();
