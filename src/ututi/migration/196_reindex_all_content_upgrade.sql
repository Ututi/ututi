SET default_text_search_config TO 'public.universal';
SELECT update_group_worker(groups.*) FROM groups;
SELECT update_page_worker(page_versions.*) FROM page_versions ORDER BY page_id, id;
SELECT update_file_worker(files.*) FROM files;
SELECT update_subject_worker(subjects.*) FROM subjects;
SELECT update_forum_post_worker(forum_posts.*) FROM forum_posts;
SELECT update_tag_worker(tags.*) FROM tags;

