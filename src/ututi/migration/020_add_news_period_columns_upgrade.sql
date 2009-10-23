alter table users add column receive_email_each varchar(30) default 'day';
alter table group_members add column receive_email_each varchar(30) default 'day';
