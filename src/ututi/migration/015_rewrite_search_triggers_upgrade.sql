CREATE OR REPLACE FUNCTION update_group_worker(groups) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        grp ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = grp.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(grp.title,''))
          || to_tsvector(coalesce(grp.description, ''))
          || to_tsvector(coalesce(grp.page, ''))
          || to_tsvector(coalesce(grp.group_id, ''))
           WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (grp.id,
          to_tsvector(coalesce(grp.title,''))
          || to_tsvector(coalesce(grp.description, ''))
          || to_tsvector(coalesce(grp.group_id, ''))
          || to_tsvector(coalesce(grp.page, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_group_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_group_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_group_search ON groups;
CREATE TRIGGER update_group_search AFTER INSERT OR UPDATE ON groups
    FOR EACH ROW EXECUTE PROCEDURE update_group_search();


CREATE OR REPLACE FUNCTION update_page_worker(page_versions) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        page ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = page.page_id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(page.title,''))
          || to_tsvector(coalesce(page.content,'')) WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (page.page_id,
          to_tsvector(coalesce(page.title,'')) || to_tsvector(coalesce(page.content, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_page_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_page_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_page_search ON page_versions;
CREATE TRIGGER update_page_search AFTER INSERT OR UPDATE ON page_versions
    FOR EACH ROW EXECUTE PROCEDURE update_page_search();


CREATE OR REPLACE FUNCTION update_subject_worker(subjects) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        subject ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = subject.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(subject.title,''))
          || to_tsvector(coalesce(subject.lecturer,''))
          || to_tsvector(coalesce(subject.description,''))
          WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (subject.id,
          to_tsvector(coalesce(subject.title,''))
          || to_tsvector(coalesce(subject.description,''))
          || to_tsvector(coalesce(subject.lecturer, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_subject_search() RETURNS trigger AS $$
    BEGIN
        PERFORM update_subject_worker(NEW);
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER update_subject_search ON subjects;
CREATE TRIGGER update_subject_search AFTER INSERT OR UPDATE ON subjects
    FOR EACH ROW EXECUTE PROCEDURE update_subject_search();

