alter table group_invitations drop constraint group_invitations_group_id_key;
alter table group_invitations add constraint group_invitations_group_id_key unique(group_id, email);
