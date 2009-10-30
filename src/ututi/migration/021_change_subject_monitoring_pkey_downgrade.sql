ALTER TABLE ONLY user_monitored_subjects
    DROP CONSTRAINT user_monitored_subjects_pkey;

ALTER TABLE ONLY user_monitored_subjects
    ADD CONSTRAINT user_monitored_subjects_pkey PRIMARY KEY (user_id, subject_id);
