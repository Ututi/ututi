CREATE TABLE forum_posts (
       id int8 not null references content_items(id),
       thread_id int8 not null references forum_posts,
       forum_id varchar(100) default null,
       title varchar(500) not null,
       message text not null,
       parent_id int8 default null references content_items(id) on delete cascade,
       primary key(id));


CREATE FUNCTION set_forum_thread_id() RETURNS trigger AS $$
    BEGIN
        IF NEW.thread_id is NULL THEN
          NEW.thread_id := NEW.id;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;


CREATE TRIGGER set_forum_thread_id BEFORE INSERT OR UPDATE ON forum_posts
    FOR EACH ROW EXECUTE PROCEDURE set_forum_thread_id();
