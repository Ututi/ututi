ALTER TABLE subjects
	DROP CONSTRAINT subjects_sub_department_id_fkey;

ALTER TABLE subjects
	DROP COLUMN sub_department_id;
