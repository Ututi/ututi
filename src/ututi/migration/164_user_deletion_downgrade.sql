ALTER TABLE ONLY public.content_items DROP CONSTRAINT content_items_created_by_fkey;

ALTER TABLE ONLY public.content_items
    ADD CONSTRAINT content_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id)  ON DELETE CASCADE;
