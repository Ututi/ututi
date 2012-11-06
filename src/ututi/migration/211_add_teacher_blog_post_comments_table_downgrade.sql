DROP TABLE teacher_blog_comments;

CREATE TRIGGER teacher_blog_post_event_trigger
	AFTER INSERT OR UPDATE ON teacher_blog_posts
	FOR EACH ROW
	EXECUTE PROCEDURE teacher_blog_post_event_trigger();
