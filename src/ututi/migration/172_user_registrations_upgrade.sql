alter table user_confirmations rename to user_registrations;
alter table user_registrations add column email_confirmed boolean default false;

alter table user_registrations add column fullname varchar(100) default null;
alter table user_registrations add column password char(36) default null;
alter table user_registrations add column openid varchar(200) default null;
alter table user_registrations add column openid_email varchar(320) default null;
alter table user_registrations add column inviter_id int8 default null references users(id) on delete set null;
alter table user_registrations add column facebook_id bigint default null;

alter table user_registrations add column id bigserial not null;
alter table user_registrations drop constraint user_confirmations_pkey;
alter table user_registrations add primary key (id);

alter table user_registrations add column completed boolean default false;
alter table user_registrations add column logo bytea default null;
alter table user_registrations add column facebook_email varchar(320) default null;

CREATE TYPE university_member_policy AS ENUM ('RESTRICT_EMAIL', 'ALLOW_INVITES', 'PUBLIC');

alter table user_registrations drop column location_id;
alter table user_registrations add column location_id int8 default null references tags(id) on delete set null;

alter table user_registrations add column university_title varchar(100) default null;
alter table user_registrations add column university_country_id int8 default null references countries(id) on delete set null;
alter table user_registrations add column university_site_url varchar(320) default null;
alter table user_registrations add column university_logo bytea default null;
alter table user_registrations add column university_member_policy university_member_policy default null;
alter table user_registrations add column university_allowed_domains text default null;

alter table countries rename column title to name;

alter table tags add column country_id int8 default null references countries(id) on delete cascade;

alter table tags add column member_policy university_member_policy default null;
alter table tags add column email_domains text default null;

alter table user_registrations add column invited_emails text default null;
alter table user_registrations add column invited_fb_ids text default null;
alter table user_registrations add column user_id int8 default null references users(id) on delete set null;
