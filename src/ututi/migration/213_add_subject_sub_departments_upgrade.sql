ALTER TABLE subjects
	ADD COLUMN sub_department_id bigint REFERENCES sub_departments(id) ON DELETE SET NULL;
