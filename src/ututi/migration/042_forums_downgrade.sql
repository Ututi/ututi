ALTER TABLE groups DROP COLUMN mailinglist_enabled;

ALTER TABLE forum_posts ADD COLUMN forum_id varchar(100) DEFAULT NULL;

UPDATE forum_posts SET forum_id =
    CASE category_id WHEN 1 THEN 'community' WHEN 2 THEN 'bugs' END;

ALTER TABLE forum_posts DROP COLUMN category_id;

DROP TABLE forum_categories;
