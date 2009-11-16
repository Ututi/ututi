alter table users add column gadugadu_uin bigint default null;
alter table users add column gadugadu_confirmed boolean default false;
alter table users add column gadugadu_confirmation_key char(32) default '';
alter table users add column gadugadu_get_news boolean default false;
