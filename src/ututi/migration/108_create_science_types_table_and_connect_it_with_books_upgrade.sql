CREATE TABLE science_types (
       id bigserial NOT NULL,
       name varchar(100) NOT NULL,
       book_department_id int8,
       PRIMARY KEY (id)
);;

alter table books add column science_type_id int8 not null references science_types(id) on delete restrict;;
