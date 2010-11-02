update content_items child set location_id = parent.location_id
       from content_items parent inner join files f on
       f.parent_id = parent.id where f.id = child.id;
