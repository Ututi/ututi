alter table content_items drop column rating;;

DROP TRIGGER update_subject_count_user ON user_monitored_subjects;
DROP TRIGGER update_subject_count_group ON group_watched_subjects;
DROP TRIGGER update_subject_count_files ON files;
DROP TRIGGER update_subject_count_pages ON pages;
DROP TRIGGER update_subject_count_content_items ON content_items;
