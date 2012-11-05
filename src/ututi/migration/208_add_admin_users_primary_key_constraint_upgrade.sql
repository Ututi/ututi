ALTER TABLE admin_users
	ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);

ALTER TABLE wall_posts
	ADD CONSTRAINT wall_posts_check CHECK (((subject_id IS NOT NULL) OR (target_location_id IS NOT NULL)));
