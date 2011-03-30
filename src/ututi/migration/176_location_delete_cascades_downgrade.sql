alter table only content_items drop constraint content_items_location_id_fkey;
ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_location_id_fkey FOREIGN KEY (location_id) REFERENCES tags(id)  ON DELETE SET NULL

alter table only user_registrations drop constraint user_registrations_location_id_fkey;
ALTER TABLE ONLY user_registrations
    ADD CONSTRAINT user_registrations_location_id_fkey FOREIGN KEY (location_id) REFERENCES tags(id)  ON DELETE SET NULL;

alter table only payments drop constraint payments_group_id_fkey;
ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id)  ON DELETE RESTRICT;
