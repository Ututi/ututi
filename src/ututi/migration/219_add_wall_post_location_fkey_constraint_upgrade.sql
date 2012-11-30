ALTER TABLE wall_posts
	ADD CONSTRAINT wall_posts_target_location_id_fkey FOREIGN KEY (target_location_id) REFERENCES tags(id) ON DELETE CASCADE;
