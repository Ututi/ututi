drop trigger tag_parent_not_null;
drop index parent_title_unique_idx;
alter table tags drop column parent_id_indexed;
create unique index parent_title_unique_idx on tags(parent_id, title_short);;
drop function tag_title_lowercase;
