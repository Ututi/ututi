insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');
insert into emails (id, email, confirmed) values (1, 'admin@ututi.lt', true);
insert into tags (title, title_short, description, tag_type)
       values ('Vilniaus universitetas', 'vu', 'Seniausias universitetas Lietuvoje.', 'location');
insert into tags (title, title_short, description, parent_id, tag_type)
       values ('Ekonomikos fakultetas', 'ef', '', 1, 'location');
