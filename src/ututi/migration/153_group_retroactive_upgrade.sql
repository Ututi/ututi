UPDATE events SET parent_id = null WHERE event_type in ('page_modified', 'subject_modified', 'subject_created', 'page_created');
select event_set_group(e.*) FROM events e WHERE e.event_type IN ('page_modified', 'subject_modified', 'subject_created', 'page_created') ORDER BY e.created asc;
