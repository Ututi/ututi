 ALTER TABLE ONLY content_tags
       DROP CONSTRAINT content_tags_tag_id_fkey;

 ALTER TABLE ONLY content_tags
       ADD CONSTRAINT content_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;

 DELETE FROM tags where title = '';
