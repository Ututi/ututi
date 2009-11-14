create table deleted_invitations (like group_invitations);

insert into deleted_invitations select gi.* from group_invitations gi
       inner join groups g on gi.group_id = g.id
       inner join group_members gm on gm.group_id = g.id
       inner join users u on u.id = gm.user_id
       inner join emails e on e.id = u.id
       where gi.email = e.email;

delete from group_invitations
       where hash in (
             select gi.hash from group_invitations gi
             inner join groups g on gi.group_id = g.id
             inner join group_members gm on gm.group_id = g.id
             inner join users u on u.id = gm.user_id
             inner join emails e on e.id = u.id
             where gi.email = e.email);

create table deleted_requests (like group_requests);

insert into deleted_requests select gr.* from group_requests gr
       inner join groups g on gr.group_id = g.id
       inner join group_members gm on gm.group_id = g.id
       inner join users u on u.id = gm.user_id
       where gr.user_id = u.id;

delete from group_requests
       where hash in (
             select gr.hash from group_requests gr
             inner join groups g on gr.group_id = g.id
             inner join group_members gm on gm.group_id = g.id
             inner join users u on u.id = gm.user_id
             where gr.user_id = u.id);
