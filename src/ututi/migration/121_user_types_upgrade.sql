alter table users add column user_type varchar(10) not null default 'user';
alter table users add column teacher_verified boolean default null;
