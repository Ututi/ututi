CREATE TABLE teacher_blog_comments (
	id bigint,
	post_id bigint NOT NULL,
	content text NOT NULL
);

ALTER TABLE teacher_blog_comments
	ADD CONSTRAINT teacher_blog_comments_pkey PRIMARY KEY (id);

ALTER TABLE teacher_blog_comments
	ADD CONSTRAINT teacher_blog_comments_id_fkey FOREIGN KEY (id) REFERENCES content_items(id) ON DELETE CASCADE;

ALTER TABLE teacher_blog_comments
	ADD CONSTRAINT teacher_blog_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES teacher_blog_posts(id) ON DELETE CASCADE;
