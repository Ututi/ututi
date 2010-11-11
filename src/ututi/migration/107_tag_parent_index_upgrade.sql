drop index parent_title_unique_idx;
alter table tags add column parent_id_indexed int8 not null default 0;;

CREATE FUNCTION tag_title_lowercase() RETURNS trigger AS $tag_parent$
    BEGIN
        NEW.title_short = LOWER(NEW.title_short);
        RETURN NEW;
    END
$tag_parent$ LANGUAGE plpgsql;;

CREATE TRIGGER tag_title_lowercase BEFORE INSERT OR UPDATE ON tags
    FOR EACH ROW EXECUTE PROCEDURE tag_title_lowercase();;

create unique index parent_title_unique_idx on tags(coalesce(parent_id, 0), title_short);;
