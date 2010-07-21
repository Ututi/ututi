alter table groups drop column private_files_lock_date;
alter table groups drop column private_files_credits;

CREATE OR REPLACE FUNCTION on_content_update() RETURNS trigger AS $$
    BEGIN
      NEW.modified_by = current_setting('ututi.active_user');
      NEW.modified_on = (now() at time zone 'UTC');
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION set_ci_modtime(content_item_id int8) RETURNS void AS $$
    BEGIN
      UPDATE content_items SET modified_by = cast(current_setting('ututi.active_user') as int8),
        modified_on = (now() at time zone 'UTC') WHERE id = content_item_id;
    END
$$ LANGUAGE plpgsql;;
