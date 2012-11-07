DROP TRIGGER check_gadugadu ON users;

DROP FUNCTION check_gadugadu();

ALTER TABLE users
	DROP COLUMN gadugadu_uin,
	DROP COLUMN gadugadu_confirmed,
	DROP COLUMN gadugadu_confirmation_key,
	DROP COLUMN gadugadu_get_news;
