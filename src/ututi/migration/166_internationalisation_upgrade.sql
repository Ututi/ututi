create table languages (
       id varchar(100) not null,
       title varchar(100) not null,
       primary key (id));;

insert into languages (title, id) values
       ('English', 'en'),
       ('Lithuanian', 'lt'),
       ('Polish', 'pl');;


create table language_texts (
       id varchar(100) not null,
       language_id varchar(100) not null references languages(id) on delete cascade,
       text text not null default '',
       primary key (id, language_id));;

insert into language_texts (id, language_id, text) values
       ('about_books', 'en', ''),
       ('about', 'en', ''),
       ('advertising', 'en', ''),
       ('group_pay', 'en', ''),
       ('banners', 'en', '');;


create table countries (
       id bigserial not null,
       title varchar(100) not null,
       timezone varchar(100) default 'UTC' not null,
       locale varchar(30) not null,
       language_id varchar(100) not null references languages(id) on delete cascade,
       primary key (id));;

insert into countries (title, timezone, locale, language_id) values
       ('Lithuania', 'Europe/Vilnius', 'lt_LT', 'lt'),
       ('Poland', 'Europe/Warsaw', 'pl_PL', 'pl');;
