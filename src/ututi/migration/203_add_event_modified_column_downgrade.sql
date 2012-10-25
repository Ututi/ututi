drop trigger after_event_comment_created on event_comments;

alter table events drop column last_activity;
