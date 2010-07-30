CREATE FUNCTION update_forum_post_worker(forum_posts) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        post ALIAS FOR $1;
        category forum_categories;
        grp groups;
    BEGIN
      EXECUTE set_ci_modtime(post.id);
      SELECT * INTO category FROM forum_categories WHERE id = post.category_id;
      SELECT * INTO grp FROM groups WHERE id = category.group_id AND forum_is_public = TRUE;
      IF FOUND OR category.group_id IS NULL THEN
        SELECT content_item_id INTO search_id FROM search_items WHERE content_item_id = post.id;
        IF FOUND THEN
          UPDATE search_items SET terms = to_tsvector(coalesce(post.title,''))
            || to_tsvector(coalesce(post.message,'')) WHERE content_item_id=search_id;
        ELSE
          INSERT INTO search_items (content_item_id, terms) VALUES (post.id,
            to_tsvector(coalesce(post.title,'')) || to_tsvector(coalesce(post.message, '')));
        END IF;
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_forum_post_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_forum_post_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_forum_post_search AFTER INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE update_forum_post_search();;

SELECT update_forum_post_worker(forum_posts.*) FROM forum_posts;
