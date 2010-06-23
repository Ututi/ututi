CREATE TABLE private_messages (id int8 references content_items(id),
       sender_id int8 not null references users(id),
       recipient_id int8 not null references users(id),
       thread_id int8 default null references private_messages(id),
       subject varchar(500) not null,
       content text default '',
       is_read boolean default false,
       primary key (id));;
