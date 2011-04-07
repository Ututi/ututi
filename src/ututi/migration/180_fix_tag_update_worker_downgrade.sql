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
