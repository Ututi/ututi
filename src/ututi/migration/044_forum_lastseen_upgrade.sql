CREATE TABLE seen_threads (
       thread_id int8 not null references forum_posts,
       user_id int8 not null references users(id),
       visited_on timestamp not null default '2000-01-01',
       primary key(thread_id, user_id));;
