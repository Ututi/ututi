DELETE FROM tags WHERE parent_id is null AND lower(title_short) NOT IN ('lsmu','vu','uni','vgtu','ktu','vpu');
