UPDATE content_items cc
       SET location_id = null
       WHERE cc.content_type = 'file';

DROP TRIGGER set_file_location ON files;

-- XXX This should have dropped the function as well, not just trigger
