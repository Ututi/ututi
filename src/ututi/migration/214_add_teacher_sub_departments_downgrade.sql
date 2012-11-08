ALTER TABLE teachers
	DROP CONSTRAINT teachers_sub_department_id_fkey;

ALTER TABLE teachers
	DROP COLUMN sub_department_id;
