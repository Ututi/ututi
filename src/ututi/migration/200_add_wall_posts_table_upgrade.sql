create table wall_posts (
       id int8 references content_items(id) on delete cascade,
       group_id int8 references groups(id) on delete cascade default null,
       subject_id int8 references subjects(id) on delete cascade default null,
       location_id int8 default null, /* Should this reference a location? */
       content text not null,
       primary key (id),
       check(group_id is not null or subject_id is not null or location_id is not null));

create or replace function wall_post_event_trigger() returns trigger as $$
    begin
        if new.group_id is not null then
            insert into events(object_id, author_id, event_type)
                   values (new.id, cast(current_setting('ututi.active_user') as int8), 'group_wall_post');
        elsif new.subject_id is not null then
            insert into events(object_id, author_id, event_type)
                   values (new.id, cast(current_setting('ututi.active_user') as int8), 'subject_wall_post');
        elsif new.location_id is not null then
            insert into events(object_id, author_id, event_type)
                   values (new.id, cast(current_setting('ututi.active_user') as int8), 'location_wall_post');
        end if;
        return new;
    end
$$ language plpgsql;

create trigger group_wall_post_event_trigger after insert or update on wall_posts
    for each row execute procedure wall_post_event_trigger();
