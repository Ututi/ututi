UPDATE events SET parent_id = null WHERE event_type in ('page_modified', 'subject_modified', 'subject_created', 'page_created');
