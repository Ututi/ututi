alter table groups drop column mailinglist_enabled;

ALTER TABLE forum_posts ALTER COLUMN category_id TYPE varchar(100) default null USING
    CASE category_id WHEN 1 THEN 'community' WHEN 2 THEN 'bugs' END;

DROP TABLE forum_categories;
