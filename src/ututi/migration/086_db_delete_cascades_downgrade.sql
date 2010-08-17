ALTER TABLE coupon_usage DROP CONSTRAINT coupon_usage_group_id_fkey;
ALTER TABLE coupon_usage ADD FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE group_members DROP CONSTRAINT group_members_membership_type_fkey;
ALTER TABLE group_members ADD FOREIGN KEY (membership_type) REFERENCES group_membership_types(membership_type);

ALTER TABLE user_monitored_subjects DROP CONSTRAINT user_monitored_subjects_subject_id_fkey;
ALTER TABLE user_monitored_subjects ADD FOREIGN KEY (subject_id) REFERENCES subjects(id);

ALTER TABLE page_versions DROP CONSTRAINT page_versions_page_id_fkey;
ALTER TABLE page_versions ADD FOREIGN KEY (page_id) REFERENCES pages(id);

ALTER TABLE subject_pages DROP CONSTRAINT subject_pages_subject_id_fkey;
ALTER TABLE subject_pages ADD FOREIGN KEY (subject_id) REFERENCES subjects(id);

ALTER TABLE subject_pages DROP CONSTRAINT subject_pages_page_id_fkey;
ALTER TABLE subject_pages ADD FOREIGN KEY (page_id) REFERENCES pages(id);

ALTER TABLE group_watched_subjects DROP CONSTRAINT group_watched_subjects_subject_id_fkey;
ALTER TABLE group_watched_subjects ADD FOREIGN KEY (subject_id) REFERENCES subjects(id);

ALTER TABLE forum_categories DROP CONSTRAINT forum_categories_group_id_fkey;
ALTER TABLE forum_categories ADD FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE forum_posts DROP CONSTRAINT forum_posts_thread_id_fkey;
ALTER TABLE forum_posts ADD FOREIGN KEY (thread_id) REFERENCES forum_posts(id);

ALTER TABLE forum_posts DROP CONSTRAINT forum_posts_category_id_fkey;
ALTER TABLE forum_posts ADD FOREIGN KEY (category_id) REFERENCES forum_categories(id);

