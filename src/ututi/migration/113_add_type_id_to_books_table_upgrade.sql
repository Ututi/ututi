alter table books add column type_id int8 NOT NULL REFERENCES book_types(id) on delete restrict;;
