ALTER TABLE users ADD COLUMN last_seen_feed timestamp not null default (now() at time zone 'UTC');
