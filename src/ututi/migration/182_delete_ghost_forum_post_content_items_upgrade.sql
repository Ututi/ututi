delete from content_items where content_type = 'forum_post' and id not in (select id from forum_posts);
