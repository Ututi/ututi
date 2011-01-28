insert into tags (title, title_short, description, tag_type)
       values ('U-niversity', 'uni', '', 'location');
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('D-epartment', 'd', '', 1, 'location');
insert into users (location_id, username, fullname, password) values (1, 'admin@uni.ututi.com', 'Administrator of the university', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');
insert into emails (id, email, confirmed) values (1, 'admin@uni.ututi.com', true);
