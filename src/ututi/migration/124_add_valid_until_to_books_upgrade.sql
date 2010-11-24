ALTER TABLE books ADD COLUMN valid_until timestamp not null default (now() at time zone 'UTC');
