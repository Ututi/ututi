drop function get_users_by_email(email_address varchar);

alter table emails drop constraint emails_pkey;
alter table emails add primary key (id, email);

alter table users add column username varchar(320);
update users set username = (select email from emails where emails.id = users.id);
alter table users alter column username set not null;

alter table users drop constraint users_location_id_fkey;
alter table users add constraint users_location_id_fkey foreign key (location_id) references tags(id) on delete cascade;

-- big step: delete all users that have no location_id
delete from users where location_id is null;

alter table users alter column location_id set not null;

alter table users add column is_local_admin bool not null default false;
alter table users add constraint user_unique_pair unique (location_id, username);
