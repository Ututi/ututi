ALTER TABLE books ADD COLUMN location_id int8 REFERENCES tags(id);;
