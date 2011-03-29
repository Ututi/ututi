create table authors (
       id bigserial not null,
       type varchar(20) not null default 'nouser',
       fullname varchar(100),
       primary key (id));;
insert into authors (id, type, fullname) select id, user_type, fullname from users;
select setval('authors_id_seq', (select max(id) from authors) + 1);

create table teachers (
       id int8 references users(id) on delete cascade,
       teacher_verified boolean default null,
       teacher_position varchar(200) default null,
       primary key (id));;

insert into teachers (id, teacher_verified, teacher_position) select id, teacher_verified, teacher_position from users where user_type = 'teacher';

alter table users alter column id type int8;
alter table users drop column user_type;
alter table users drop column teacher_verified;
alter table users drop column teacher_position;

ALTER TABLE ONLY users
    ADD CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES authors(id)  ON DELETE CASCADE;

CREATE FUNCTION delete_user() RETURNS trigger AS $$
    BEGIN
        UPDATE authors SET type = 'nouser' WHERE id = OLD.id;
        RETURN OLD;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER delete_user BEFORE DELETE ON users
    FOR EACH ROW EXECUTE PROCEDURE delete_user();;

alter table content_items drop constraint content_items_created_by_fkey;
alter table content_items drop constraint content_items_deleted_by_fkey;
alter table content_items drop constraint content_items_modified_by_fkey;

ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES authors(id)  ON DELETE cascade;

ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES authors(id)  ON DELETE cascade;

ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_modified_by_fkey FOREIGN KEY (modified_by) REFERENCES authors(id)  ON DELETE cascade;

alter table teacher_taught_subjects add column teacher_id int8 references teachers(id) on delete cascade default null;
update teacher_taught_subjects set teacher_id = user_id;
alter table teacher_taught_subjects drop constraint teacher_tought_subjects_pkey;
alter table teacher_taught_subjects drop column user_id;
alter table teacher_taught_subjects alter column teacher_id set not null;
alter table teacher_taught_subjects add primary key (teacher_id, subject_id);

alter table teacher_groups add column teacher_id int8 references teachers(id) on delete cascade default null;
update teacher_groups set teacher_id = user_id;
alter table teacher_groups drop column user_id;
alter table teacher_groups alter column teacher_id set not null;

