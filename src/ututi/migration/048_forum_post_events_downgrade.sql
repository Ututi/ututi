ALTER TABLE events DROP COLUMN post_id;

UPDATE events SET event_type = 'forum_post_created' WHERE event_type = 'mailinglist_post_created';

DROP TRIGGER group_forum_message_event_trigger ON forum_posts;

DROP FUNCTION group_forum_message_event_trigger();
