alter table users add column hide_suggest_create_group boolean default false;
alter table users add column hide_suggest_watch_subject boolean default false;

update users set hide_suggest_create_group = position('suggest_create_group' in hidden_blocks) <> 0;
update users set hide_suggest_watch_subject = position('suggest_watch_subject' in hidden_blocks) <> 0;

alter table users drop column hidden_blocks;
