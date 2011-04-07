alter table user_registrations alter column university_member_policy set default 'ALLOW_INVITES';
update tags set member_policy = 'PUBLIC' where tag_type = 'location' and member_policy is null;
alter table tags alter column member_policy set default null;
alter table tags add constraint location_member_policy_not_null check (member_policy is not null or tag_type != 'location');
