alter table tags add column theme_id int8 default null references themes(id) on delete set null;
