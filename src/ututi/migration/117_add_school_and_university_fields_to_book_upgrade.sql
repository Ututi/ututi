alter table books add column department_id int8 NOT NULL ;;
alter table books add column school_grade_id int8 NOT NULL REFERENCES school_grades(id) on delete restrict;;
alter table books add column course varchar(100) default '';;
