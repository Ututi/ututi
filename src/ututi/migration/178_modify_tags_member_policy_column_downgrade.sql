alter table user_registrations alter column university_member_policy set default 'RESTRICT_EMAIL';
alter table tags alter column member_policy set default 'RESTRICT_EMAIL';
alter table tags drop constraint location_member_policy_not_null;
