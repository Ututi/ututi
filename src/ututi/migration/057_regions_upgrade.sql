/* A table for regions */
CREATE TABLE regions (id bigserial NOT NULL,
       title varchar(250) NOT NULL,
       country varchar(2) NOT NULL,
       PRIMARY KEY (id));;

ALTER TABLE tags ADD COLUMN region_id int8 DEFAULT NULL references regions(id) ON DELETE RESTRICT;
