alter table content_items add column deleted_by int8 references users(id) default null;
alter table content_items add column deleted_on timestamp default null;
