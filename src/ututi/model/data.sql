insert into tags (title, title_short, description, tag_type, member_policy)
       values ('U-niversity', 'uni', '', 'location', 'PUBLIC');
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('D-epartment', 'd', '', 1, 'location');

insert into authors (type, fullname) values ('user', 'Administrator of the university');
insert into users (id, location_id, username, password) values (1, 1, 'admin@uni.ututi.com', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');
insert into emails (id, email, confirmed) values (1, 'admin@uni.ututi.com', true);

insert into user_registrations (location_id, hash, email)
       values (1, 'test', 'user@example.com')
