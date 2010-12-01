ALTER TABLE books ADD COLUMN owner_name varchar(50) DEFAULT '' NOT NULL;
ALTER TABLE books ADD COLUMN owner_phone varchar(50) DEFAULT '' NOT NULL;
ALTER TABLE books ADD COLUMN owner_email varchar(100) DEFAULT '' NOT NULL;
ALTER TABLE books DROP COLUMN show_phone;
