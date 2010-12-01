ALTER TABLE books DROP COLUMN owner_name;
ALTER TABLE books DROP COLUMN owner_phone;
ALTER TABLE books DROP COLUMN owner_email;
ALTER TABLE books ADD COLUMN show_phone boolean DEFAULT TRUE;
