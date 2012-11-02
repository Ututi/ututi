insert into languages (title, id) values
       ('English', 'en'),
       ('Lithuanian', 'lt'),
       ('Polish', 'pl');;

insert into language_texts (id, language_id, text) values
       ('about_books', 'en', ''),
       ('about', 'en', ''),
       ('advertising', 'en', ''),
       ('group_pay', 'en', ''),
       ('banners', 'en', '');;

insert into countries (name, timezone, locale, language_id) values
       ('Lithuania', 'Europe/Vilnius', 'lt_LT', 'lt'),
       ('Poland', 'Europe/Warsaw', 'pl_PL', 'pl');;

/* Create first user=admin and password=asdasd */
insert into admin_users (email, fullname, password) values ('admin@ututi.lt', 'Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7');;

insert into group_membership_types (membership_type)
                      values ('administrator');;
insert into group_membership_types (membership_type)
                      values ('member');;
