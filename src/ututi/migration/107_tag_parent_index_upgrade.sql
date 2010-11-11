alter table tags add column parent_id_indexed int8 not null default 0;;
 
CREATE FUNCTION tag_parent_not_null() RETURNS trigger AS $tag_parent$
    BEGIN
        NEW.title_short = LOWER(NEW.title_short);
        IF NEW.parent_id IS NULL THEN
           NEW.parent_id_indexed := 0;
        ELSE
           NEW.parent_id_indexed := NEW.parent_id;
        END IF;

        RETURN NEW;
    END
$tag_parent$ LANGUAGE plpgsql;;

CREATE TRIGGER tag_parent_not_null BEFORE INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE tag_parent_not_null();;

drop index parent_title_unique_idx on tags;

create unique index parent_title_unique_idx on tags(parent_id_indexed, title_short);;
