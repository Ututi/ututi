CREATE OR REPLACE FUNCTION update_subject_count_content_items() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  <<func>> DECLARE
    val content_items;
    subject content_items;
    id int8 := NULL;
    content_type varchar(20) := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        val := OLD;
        id := OLD.id;
        content_type := OLD.content_type;
    ELSE
        val := NEW;
        id := NEW.id;
        content_type := NEW.content_type;
    END IF;

    IF content_type = 'subject' THEN
        RETURN val;
    END IF;

    IF content_type = 'file' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN files f on f.parent_id = parent.id
          WHERE f.id = func.id AND parent.content_type = 'subject';
        IF FOUND THEN
          PERFORM subject_rating_worker(subject);
         END IF;
    ELSIF content_type = 'page' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN subject_pages sp on sp.subject_id = parent.id
          WHERE sp.page_id = func.id AND parent.content_type = 'subject';
        IF FOUND THEN
            PERFORM subject_rating_worker(subject);
        END IF;
    END IF;


    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$;


CREATE OR REPLACE FUNCTION update_subject_count_files() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  <<func>> DECLARE
    subject content_items;
    id int8 := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        id = OLD.id;
    ELSE
        id = NEW.id;
    END IF;
    SELECT parent.* FROM content_items parent INTO subject
        INNER JOIN files f on f.parent_id = parent.id
        WHERE f.id = func.id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$;


CREATE OR REPLACE FUNCTION update_subject_count_pages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  <<func>> DECLARE
    subject content_items;
    id int8 := NULL;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        id = OLD.id;
    ELSE
        id = NEW.id;
    END IF;
    SELECT parent.* FROM content_items parent INTO subject
        INNER JOIN subject_pages sp on sp.subject_id = parent.id
        WHERE sp.page_id = func.id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$;
