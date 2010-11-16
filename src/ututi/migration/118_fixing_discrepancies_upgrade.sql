alter table tags drop column parent_id_indexed;
alter table group_mailing_list_messages alter column original set not null;
alter table science_types alter column book_department_id set not null;
alter table tags drop constraint uniq_location_tag;
alter table books drop constraint books_owner_id_fkey;
alter table books add constraint books_owner_id_fkey foreign key (owner_id) references users(id) on delete cascade;
