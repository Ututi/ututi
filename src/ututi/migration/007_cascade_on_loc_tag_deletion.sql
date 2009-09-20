-- The location tag's parent should cascade on deletion, while all the objects marked with the tag should be set to null

ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_parent_id_fkey;

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES tags(id)  ON DELETE CASCADE;


ALTER TABLE ONLY public.content_items DROP CONSTRAINT content_items_location_id_fkey;

ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_location_id_fkey FOREIGN KEY (location_id) REFERENCES tags(id) ON DELETE SET NULL;
