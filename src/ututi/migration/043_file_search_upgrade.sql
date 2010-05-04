CREATE OR REPLACE FUNCTION update_file_worker(files) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        file ALIAS FOR $1;
    BEGIN
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = file.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(file.title,''))
          || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')) WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (file.id,
          to_tsvector(coalesce(file.title,'')) || to_tsvector(coalesce(file.filename,'')) || to_tsvector(coalesce(file.description,'')));
      END IF;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_file_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_file_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_file_search ON files;
CREATE TRIGGER update_file_search AFTER INSERT OR UPDATE ON files
    FOR EACH ROW EXECUTE PROCEDURE update_file_search();

SELECT update_file_worker(files.*) FROM files;
