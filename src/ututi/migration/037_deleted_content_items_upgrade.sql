update content_items set deleted_by = 1 where deleted_by is null and deleted_on is not null;
