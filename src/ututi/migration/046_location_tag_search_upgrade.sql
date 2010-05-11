DROP TABLE IF EXISTS tag_search_items;
CREATE TABLE tag_search_items (
       tag_id int8 NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
       terms tsvector,
       PRIMARY KEY (tag_id));;

CREATE index tag_search_idx ON tag_search_items USING gin(terms);;

CREATE OR REPLACE FUNCTION make_vector(attrs text[]) RETURNS tsvector AS $$
    DECLARE
      str text := NULL;
      vector tsvector := NULL;
    BEGIN
      SELECT coalesce(array_to_string($1, ' '), '') INTO str;
      SELECT to_tsvector(str) INTO vector;
      RETURN vector;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION tag_indexable_content(int8) RETURNS tsvector AS $$
    DECLARE
        tag_id ALIAS FOR $1;
        tag tags;
        vector tsvector := NULL;
    BEGIN
        SELECT * FROM tags INTO tag WHERE id = tag_id AND tag_type = 'location';
        IF FOUND AND NOT tag_id IS NULL THEN
          SELECT make_vector(ARRAY[tag.title, tag.title_short, tag.description, tag.site_url]) INTO vector;
          RETURN vector;
        ELSE
          RETURN to_tsvector('');
        END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_tag_worker(tags) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        tag ALIAS FOR $1;
        vector tsvector := NULL;
    BEGIN
      SELECT INTO vector tag_indexable_content(tags.id) || tag_indexable_content(tags.parent_id) FROM tags WHERE id = tag.id;
      SELECT tag_id INTO search_id FROM tag_search_items WHERE tag_id = tag.id;

      IF FOUND and tag.tag_type = 'location' THEN
        UPDATE tag_search_items SET terms = vector
          WHERE tag_id=search_id;
      ELSE
        INSERT INTO tag_search_items (tag_id, terms) VALUES (tag.id, vector);
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION update_tag_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_tag_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_tag_search AFTER INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE update_tag_search();;

SELECT update_tag_worker(tags.*) FROM tags WHERE tag_type = 'location';;
