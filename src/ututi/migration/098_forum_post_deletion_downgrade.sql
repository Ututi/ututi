ALTER TABLE ONLY seen_threads
    DROP CONSTRAINT seen_threads_thread_id_fkey;
ALTER TABLE ONLY seen_threads
    ADD CONSTRAINT seen_threads_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES forum_posts;

ALTER TABLE ONLY subscribed_threads
    DROP CONSTRAINT subscribed_threads_thread_id_fkey;
ALTER TABLE ONLY subscribed_threads
    ADD CONSTRAINT subscribed_threads_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES forum_posts;
