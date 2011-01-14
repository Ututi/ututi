CREATE TABLE event_comments (id int8 references content_items(id),
       event_id int8 not null references events(id) on delete cascade,
       content text default '',
       primary key (id));;

CREATE INDEX event_comments_event_id_idx ON event_comments (event_id);;
