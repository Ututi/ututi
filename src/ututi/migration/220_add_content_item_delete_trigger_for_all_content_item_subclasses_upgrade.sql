CREATE TRIGGER delete_content_item_after_forum_post_delete
	AFTER DELETE ON forum_posts
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_private_message_delete
	AFTER DELETE ON private_messages
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_file_delete
	AFTER DELETE ON files
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_group_delete
	AFTER DELETE ON groups
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_subject_delete
	AFTER DELETE ON subjects
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_event_comment_delete
	AFTER DELETE ON event_comments
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_page_delete
	AFTER DELETE ON pages
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_blog_comment_delete
	AFTER DELETE ON teacher_blog_comments
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_blog_post_delete
	AFTER DELETE ON teacher_blog_posts
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();

CREATE TRIGGER delete_content_item_after_wall_post_delete
	AFTER DELETE ON wall_posts
	FOR EACH ROW
	EXECUTE PROCEDURE delete_content_item();
