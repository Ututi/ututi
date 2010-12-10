alter table books add column course varchar(100) default '';
alter table books add column location_id int8 REFERENCES tags(id);
