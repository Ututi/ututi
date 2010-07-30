ALTER TABLE ONLY file_downloads
      DROP CONSTRAINT file_downloads_file_id_fkey;

ALTER TABLE ONLY file_downloads
      ADD CONSTRAINT file_downloads_file_id_fkey FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE;
