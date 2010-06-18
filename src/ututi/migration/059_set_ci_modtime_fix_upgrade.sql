CREATE OR REPLACE FUNCTION add_event(event_id int8, evtype varchar) RETURNS void AS $$
    BEGIN
      INSERT INTO events (object_id, author_id, event_type)
             VALUES (event_id, cast(current_setting('ututi.active_user') as int8), evtype);
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION set_ci_modtime(content_item_id int8) RETURNS void AS $$
    BEGIN
      UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
        modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
    END
$$ LANGUAGE plpgsql;;

