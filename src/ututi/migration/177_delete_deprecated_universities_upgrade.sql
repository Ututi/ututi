DELETE FROM tags WHERE parent_id is null AND title_short NOT IN ('LSMU','VU','UNI','VGTU','KTU','VPU');
