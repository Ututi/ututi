DROP FUNCTION create_i18n_text();

DROP TRIGGER teacher_insert_trg ON teachers;
DROP FUNCTION teacher_insert_trg();

DROP TRIGGER teacher_delete_trg ON teachers;
DROP FUNCTION teacher_delete_trg();

ALTER TABLE teachers ALTER COLUMN general_info_id DROP NOT NULL;
ALTER TABLE teachers DROP CONSTRAINT teachers_general_info_id_fkey;

DELETE FROM i18n_texts WHERE id IN (SELECT general_info_id FROM teachers);

ALTER TABLE teachers DROP COLUMN general_info_id;
