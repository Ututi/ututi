ALTER TABLE teachers
	ADD COLUMN sub_department_id bigint;

ALTER TABLE teachers
	ADD CONSTRAINT teachers_sub_department_id_fkey FOREIGN KEY (sub_department_id) REFERENCES sub_departments(id) ON DELETE SET NULL;
