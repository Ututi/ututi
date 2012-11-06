CREATE TABLE teacher_blog_posts (
	id bigint NOT NULL,
	title character varying(250) NOT NULL,
	description text NOT NULL
);

CREATE OR REPLACE FUNCTION teacher_blog_post_event_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
        insert into events(object_id, author_id, event_type)
               values (new.id, cast(current_setting('ututi.active_user') as int8), 'teacher_blog_post');
        return new;
    end
$$;


ALTER TABLE teacher_blog_posts
	ADD CONSTRAINT teacher_blog_posts_pkey PRIMARY KEY (id);

ALTER TABLE teacher_blog_posts
	ADD CONSTRAINT teacher_blog_posts_id_fkey FOREIGN KEY (id) REFERENCES content_items(id) ON DELETE CASCADE;

CREATE TRIGGER teacher_blog_post_event_trigger
	AFTER INSERT OR UPDATE ON teacher_blog_posts
	FOR EACH ROW
	EXECUTE PROCEDURE teacher_blog_post_event_trigger();
