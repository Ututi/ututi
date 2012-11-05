ALTER TABLE subjects
	ADD COLUMN visibility character varying(40) DEFAULT 'everyone'::character varying NOT NULL,
	ADD COLUMN edit_settings_perm character varying(40) DEFAULT 'everyone'::character varying NOT NULL,
	ADD COLUMN post_discussion_perm character varying(40) DEFAULT 'everyone'::character varying NOT NULL;
