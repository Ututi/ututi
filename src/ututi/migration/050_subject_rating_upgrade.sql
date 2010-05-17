CREATE OR REPLACE FUNCTION update_page_location() RETURNS trigger AS $$
    BEGIN
      IF NEW.content_type <> 'subject' OR NEW.location_id = OLD.location_id THEN
        RETURN NEW;
      END IF;
      UPDATE content_items SET location_id = NEW.location_id
             FROM subject_pages s
             WHERE s.page_id = id
             AND s.subject_id = NEW.id;

      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

ALTER TABLE search_items ADD COLUMN rating int NOT NULL DEFAULT 0;;

CREATE OR REPLACE FUNCTION subject_rating_worker(content_items) RETURNS void AS $$
  DECLARE
      page_count int := 0;
      file_count int := 0;
      group_count int := 0;
      user_count int := 0;
      subject ALIAS FOR $1;
  BEGIN
    IF subject.content_type = 'subject' THEN
      SELECT COUNT(id) INTO page_count FROM subject_pages sp
        INNER JOIN content_items pg ON pg.id = sp.page_id
        WHERE sp.subject_id = subject.id
          AND pg.deleted_on IS NULL;
      SELECT COUNT(f.id) INTO file_count FROM files f
        INNER JOIN content_items fi ON fi.id = f.id
          WHERE f.parent_id = subject.id
          AND fi.deleted_on IS NULL;
      SELECT COUNT(group_id) INTO group_count FROM group_watched_subjects
        WHERE subject_id = subject.id;
      SELECT COUNT(user_id) INTO user_count FROM user_monitored_subjects
        WHERE ignored = false and subject_id = subject.id;
      UPDATE search_items SET rating = page_count + file_count + group_count + user_count
        WHERE content_item_id = subject.id;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_watches() RETURNS trigger as $$
  DECLARE
    subject content_items;
  BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT * FROM content_items INTO subject WHERE id = OLD.subject_id AND content_type = 'subject';
    ELSE
        SELECT * FROM content_items INTO subject WHERE id = NEW.subject_id AND content_type = 'subject';
    END IF;
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_pages() RETURNS trigger as $$
  DECLARE
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
        WHERE sp.page_id = id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_count_files() RETURNS trigger as $$
  DECLARE
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
        WHERE f.id = id AND parent.content_type = 'subject';
    IF FOUND THEN
        PERFORM subject_rating_worker(subject);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
  END
$$ LANGUAGE plpgsql;;


CREATE OR REPLACE FUNCTION update_subject_count_content_items() RETURNS trigger as $$
  DECLARE
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
          WHERE f.id = id AND parent.content_type = 'subject';
        IF FOUND THEN
          PERFORM subject_rating_worker(subject);
         END IF;
    ELSIF content_type = 'page' THEN
        SELECT parent.* FROM content_items parent INTO subject
          INNER JOIN subject_pages sp on sp.subject_id = parent.id
          WHERE sp.page_id = id AND parent.content_type = 'subject';
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
$$ LANGUAGE plpgsql;;


CREATE TRIGGER update_subject_count_user AFTER INSERT OR UPDATE OR DELETE ON user_monitored_subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_watches();;

CREATE TRIGGER update_subject_count_group AFTER INSERT OR UPDATE OR DELETE ON group_watched_subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_watches();;

CREATE TRIGGER update_subject_count_files AFTER INSERT OR UPDATE OR DELETE ON files
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_files();;

CREATE TRIGGER update_subject_count_pages AFTER INSERT OR UPDATE OR DELETE ON pages
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_pages();;

CREATE TRIGGER update_subject_count_content_items AFTER INSERT OR UPDATE OR DELETE ON content_items
    FOR EACH ROW EXECUTE PROCEDURE update_subject_count_content_items();;

SELECT subject_rating_worker(content_items.*) FROM content_items WHERE content_type = 'subject' AND deleted_on IS NULL;;
