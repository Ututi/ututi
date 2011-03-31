alter table user_registrations alter column university_member_policy set default 'RESTRICT_EMAIL';
alter table tags alter column member_policy drop not null;
alter table tags alter column member_policy set default 'RESTRICT_EMAIL';
