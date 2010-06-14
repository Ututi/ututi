CREATE OR REPLACE FUNCTION set_ci_modtime(id int8) RETURNS void AS $$
    BEGIN
      UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
        modified_on = (now() at time zone 'UTC') WHERE id = id;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_group_worker(groups) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        grp ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(grp.id);
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
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_page_worker(page_versions) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        page ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(page.page_id);
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = page.page_id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(page.title,''))
          || to_tsvector(coalesce(page.content,'')) WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (page.page_id,
          to_tsvector(coalesce(page.title,'')) || to_tsvector(coalesce(page.content, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_file_worker(files) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        parent_type varchar(20) := NULL;
        file ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(file.id);
      SELECT ci.content_type INTO parent_type FROM content_items ci WHERE ci.id = file.parent_id;
      IF parent_type = 'subject' THEN
        SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = file.id;
        IF FOUND THEN
          UPDATE search_items SET terms = to_tsvector(coalesce(file.title,''))
            || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')) WHERE content_item_id=search_id;
        ELSE
          INSERT INTO search_items (content_item_id, terms) VALUES (file.id,
            to_tsvector(coalesce(file.title,'')) || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')));
        END IF;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_subject_worker(subjects) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        subject ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(subject.id);
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
$$ LANGUAGE plpgsql;;
