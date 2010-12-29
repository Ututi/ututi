CREATE OR REPLACE FUNCTION on_content_update() RETURNS trigger AS $$
BEGIN
  IF (current_setting('ututi.active_user') <> '') THEN
       IF CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
              NEW.modified_by = current_setting('ututi.active_user');
              NEW.modified_on = (now() at time zone 'UTC');
       END IF;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION set_ci_modtime(content_item_id int8) RETURNS void AS $$
BEGIN
    IF (current_setting('ututi.active_user') <> '') AND
        CAST(current_setting('ututi.active_user') AS int8) > 0 THEN
        UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
               modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
    END IF;
END
$$ LANGUAGE plpgsql;;

