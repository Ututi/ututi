/* Creates a new i18n_text object and returns it's id. */
CREATE FUNCTION create_i18n_text() RETURNS int8 AS $$
    BEGIN
        INSERT INTO i18n_texts DEFAULT VALUES;
        RETURN currval(pg_get_serial_sequence('i18n_texts', 'id'));
    END
$$ LANGUAGE plpgsql;;

alter table teachers add column general_info_id int8 references i18n_texts(id) on delete restrict;

/* Migrate data. */

update teachers set general_info_id = create_i18n_text();

insert into i18n_texts_versions (i18n_texts_id, language_id, text)
    select t.general_info_id as i18n_texts_id,
           'lt' as language_id,
           u.description as text
    from users u, teachers t
    where u.id = t.id and u.description is not null;

/* Add not null constraint and triggers. */

alter table teachers alter column general_info_id set not null;

CREATE FUNCTION teacher_insert_trg() RETURNS TRIGGER AS $$
    BEGIN
        NEW.general_info_id := create_i18n_text();
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER teacher_insert_trg BEFORE INSERT ON teachers FOR EACH ROW
    EXECUTE PROCEDURE teacher_insert_trg();

CREATE FUNCTION teacher_delete_trg() RETURNS trigger AS $$
    BEGIN
        DELETE FROM i18n_texts WHERE id = OLD.general_info_id;
        RETURN NULL;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER teacher_delete_trg AFTER DELETE ON teachers FOR EACH ROW
    EXECUTE PROCEDURE teacher_delete_trg();
