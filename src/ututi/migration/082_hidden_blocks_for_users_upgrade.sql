alter table users add column hidden_blocks text default '';

update users set hidden_blocks = hidden_blocks || ' ' || 'suggest_create_group' where hide_suggest_create_group = true;
update users set hidden_blocks = hidden_blocks || ' ' || 'suggest_watch_subject' where hide_suggest_watch_subject = true;

alter table users drop column hide_suggest_create_group;
alter table users drop column hide_suggest_watch_subject;
