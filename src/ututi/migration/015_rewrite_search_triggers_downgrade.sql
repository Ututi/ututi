CREATE OR REPLACE FUNCTION update_group_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = NEW.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.description, ''))
          || to_tsvector(coalesce(NEW.page, ''))
          || to_tsvector(coalesce(NEW.group_id, ''))
           WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (NEW.id,
          to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.description, ''))
          || to_tsvector(coalesce(NEW.group_id, ''))
          || to_tsvector(coalesce(NEW.page, '')));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_group_search ON groups;
CREATE TRIGGER update_group_search AFTER INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE update_group_search();

CREATE OR REPLACE FUNCTION update_page_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = NEW.page_id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.content,'')) WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (NEW.page_id,
          to_tsvector(coalesce(NEW.title,'')) || to_tsvector(coalesce(NEW.content, '')));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_page_search ON page_versions;
CREATE TRIGGER update_page_search AFTER INSERT OR UPDATE ON page_versions
    FOR EACH ROW EXECUTE PROCEDURE update_page_search();

CREATE OR REPLACE FUNCTION update_subject_search() RETURNS trigger AS $$
    DECLARE
        search_id int8 := NULL;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = NEW.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.lecturer,''))
          || to_tsvector(coalesce(NEW.description,''))
          WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (NEW.id,
          to_tsvector(coalesce(NEW.title,''))
          || to_tsvector(coalesce(NEW.description,''))
          || to_tsvector(coalesce(NEW.lecturer, '')));
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_subject_search ON subjects;
CREATE TRIGGER update_subject_search AFTER INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_search();
