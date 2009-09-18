-- Old tables

ALTER TABLE ONLY public.group_files DROP CONSTRAINT group_files_group_id_fkey;

ALTER TABLE ONLY group_files
    ADD CONSTRAINT group_files_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


ALTER TABLE ONLY public.group_mailing_list_attachments DROP CONSTRAINT group_mailing_list_attachments_message_id_fkey;

ALTER TABLE ONLY group_mailing_list_attachments
    ADD CONSTRAINT group_mailing_list_attachments_message_id_fkey FOREIGN KEY (message_id, group_id) REFERENCES group_mailing_list_messages(message_id, group_id);


-- Group mailing list IDs

ALTER TABLE ONLY public.group_mailing_list_messages DROP CONSTRAINT group_mailing_list_messages_thread_group_id_fkey;
ALTER TABLE ONLY public.group_mailing_list_messages DROP CONSTRAINT group_mailing_list_messages_reply_to_group_id_fkey;
ALTER TABLE ONLY public.group_mailing_list_messages DROP CONSTRAINT group_mailing_list_messages_group_id_fkey;

ALTER TABLE ONLY group_mailing_list_messages
    ADD CONSTRAINT group_mailing_list_messages_reply_to_group_id_fkey FOREIGN KEY (reply_to_group_id) REFERENCES groups(id);

ALTER TABLE ONLY group_mailing_list_messages
    ADD CONSTRAINT group_mailing_list_messages_thread_group_id_fkey FOREIGN KEY (thread_group_id) REFERENCES groups(id);

ALTER TABLE ONLY group_mailing_list_messages
    ADD CONSTRAINT group_mailing_list_messages_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


-- Search items

ALTER TABLE ONLY public.search_items DROP CONSTRAINT search_items_content_item_id_fkey;

ALTER TABLE ONLY search_items
    ADD CONSTRAINT search_items_content_item_id_fkey FOREIGN KEY (content_item_id) REFERENCES content_items(id);

-- File parents

ALTER TABLE ONLY public.files DROP CONSTRAINT files_parent_id_fkey;

ALTER TABLE ONLY files
    ADD CONSTRAINT files_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES content_items(id);

-- Watched subjects

ALTER TABLE ONLY public.group_watched_subjects DROP CONSTRAINT group_watched_subjects_group_id_fkey;

ALTER TABLE ONLY group_watched_subjects
    ADD CONSTRAINT group_watched_subjects_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


-- Group invitations and join requests

ALTER TABLE ONLY public.group_invitations DROP CONSTRAINT group_invitations_group_id_fkey;

ALTER TABLE ONLY group_invitations
    ADD CONSTRAINT group_invitations_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


ALTER TABLE ONLY public.group_requests DROP CONSTRAINT group_requests_group_id_fkey;

ALTER TABLE ONLY group_requests
    ADD CONSTRAINT group_requests_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


-- Group members

ALTER TABLE ONLY public.group_members DROP CONSTRAINT group_members_group_id_fkey;

ALTER TABLE ONLY group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);
