update content_items set deleted_on = null where deleted_by is null and deleted_on is not null;
