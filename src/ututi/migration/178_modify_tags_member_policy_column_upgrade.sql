alter table user_registrations alter column university_member_policy set default 'ALLOW_INVITES';
update tags set member_policy = 'PUBLIC' where member_policy is null;
alter table tags alter column member_policy set not null;
alter table tags alter column member_policy set default 'ALLOW_INVITES';
