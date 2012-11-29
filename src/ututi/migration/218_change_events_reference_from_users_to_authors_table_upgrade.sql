ALTER TABLE events
	DROP CONSTRAINT events_author_id_fkey;

ALTER TABLE events
	ADD CONSTRAINT events_author_id_fkey FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE;
