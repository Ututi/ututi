create table i18n_texts (
       id bigserial not null,
       primary key (id));


create table i18n_texts_versions (
       i18n_texts_id int8 not null references i18n_texts(id) on delete cascade,
       language_id varchar(100) not null references languages(id) on delete cascade,
       text text not null default '',
       primary key (i18n_texts_id, language_id));;
