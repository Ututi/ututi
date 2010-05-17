CREATE TABLE subscribed_threads (
       thread_id int8 not null references forum_posts,
       user_id int8 not null references users(id),
       active boolean default true,
       primary key(thread_id, user_id));;
