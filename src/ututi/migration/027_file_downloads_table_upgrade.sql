create table file_downloads (file_id int8 references content_items(id),
       user_id int8 references users(id),
       download_time timestamp not null default (now() at time zone 'UTC'),
       primary key (file_id, user_id, download_time));

create index user_id on file_downloads (user_id);
create index file_id on file_downloads (file_id);

