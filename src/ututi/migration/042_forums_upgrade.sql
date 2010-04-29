alter table groups add column mailinglist_enabled bool default true;

CREATE TABLE forum_categories (
       id bigserial not null,
       group_id int8 null references groups(id),
       title varchar(255) not null default '',
       description text not null default '',
       primary key (id));

insert into forum_categories (group_id, title, description)
    values (null, 'Community', 'Ututi community forum');
insert into forum_categories (group_id, title, description)
    values (null, 'Report a bug', 'Report bugs here.' );

ALTER TABLE forum_posts ALTER COLUMN forum_id DROP DEFAULT;

ALTER TABLE forum_posts ALTER COLUMN forum_id TYPE int8 USING
    CASE forum_id WHEN 'community' THEN 1 WHEN 'bugs' THEN 2 END;

ALTER TABLE forum_posts ADD FOREIGN KEY (forum_id)
    REFERENCES forum_categories(id);
