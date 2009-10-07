SELECT update_group_worker(groups.*) FROM groups;
SELECT update_page_worker(page_versions.*) FROM page_versions ORDER BY page_id, id;
SELECT update_subject_worker(subjects.*) FROM subjects;
