insert into group_invitations select * from deleted_invitations;

drop table deleted_invitations;

insert into group_requests select * from deleted_requests;

drop table deleted_requests;
