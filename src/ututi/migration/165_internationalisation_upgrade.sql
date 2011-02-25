create table languages (
       id bigserial not null,
       title varchar(100) not null,
       lang varchar(5) not null,
       primary key (id));;

insert into languages (title, lang) values
       ('English', 'en'),
       ('Lithuanian', 'lt'),
       ('Polish', 'pl');;


create table language_texts (
       id varchar(100) not null,
       language_id int8 not null references languages(id),
       title varchar(100) not null,
       text text not null default '',
       primary key (id, language_id));;

insert into language_texts (id, language_id, title, text) values
       ('about_books', 1, 'About books', ''),
       ('about', 1, 'About ututi', ''),
       ('advertising', 1, 'Advertising', ''),
       ('group_pay', 1, 'Pay', ''),
       ('banners', 1, 'Banners', '');;


create table countries (
       id bigserial not null,
       title varchar(100) not null,
       timezone varchar(100) default 'UTC' not null,
       locale varchar(30) not null,
       language_id int8 not null references languages(id),
       primary key (id));;

insert into countries (title, timezone, locale, language_id) values
       ('Lithuania', 'Europe/Vilnius', 'lt_LT', 1),
       ('Poland', 'Europe/Warsaw', 'pl_PL', 2);;
