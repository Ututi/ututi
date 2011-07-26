create table school_grades (
       id bigserial not null,
       name varchar(20) not null,
       primary key (id));;


create table cities (
       id bigserial not null,
       name varchar(100) not null,
       priority int8 NOT NULL DEFAULT 0,
       primary key (id)
);;

CREATE TABLE science_types (
       id bigserial NOT NULL,
       name varchar(100) NOT NULL,
       book_department_id int8 NOT NULL, -- actualy an enum
       PRIMARY KEY (id)
);;

create table book_types (
       id bigserial not null,
       name varchar(100) not null,
       url_name varchar(100) not null,
       primary key (id)
);;

CREATE TABLE books (
       id int8 references content_items(id) on delete cascade,
       title varchar(100) NOT NULL,
       description text,
       author varchar(100),
       price varchar(250) DEFAULT '' NOT NULL,
       logo bytea DEFAULT NULL,
       city_id int8 DEFAULT NULL REFERENCES cities(id) on delete restrict,
       science_type_id int8 REFERENCES science_types(id) on delete restrict,
       type_id int8 REFERENCES book_types(id) on delete restrict,
       department_id int8 NOT NULL,
       school_grade_id int8 REFERENCES school_grades(id) on delete restrict,
       owner_name varchar(50) DEFAULT '',
       owner_phone varchar(50) DEFAULT '',
       owner_email varchar(100) DEFAULT '',
       valid_until timestamp not null default (now() at time zone 'UTC'),
       PRIMARY KEY (id)
);;

CREATE FUNCTION update_book_worker(books) RETURNS void AS $$
    DECLARE
        search_id int8 := NULL;
        parent_type varchar(20) := NULL;
        book ALIAS FOR $1;
    BEGIN
      EXECUTE set_ci_modtime(book.id);
      SELECT content_item_id INTO search_id  FROM search_items WHERE content_item_id = book.id;
      IF FOUND THEN
        UPDATE search_items SET terms = to_tsvector(coalesce(book.title,''))
          || to_tsvector(coalesce(book.description,''))
          || to_tsvector(coalesce(book.author,''))
          WHERE content_item_id=search_id;
      ELSE
        INSERT INTO search_items (content_item_id, terms) VALUES (book.id,
          to_tsvector(coalesce(book.title,''))
          || to_tsvector(coalesce(book.description,''))
          || to_tsvector(coalesce(book.author, '')));
      END IF;
    END
$$ LANGUAGE plpgsql;;

CREATE FUNCTION update_book_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_book_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

CREATE TRIGGER update_book_search AFTER INSERT OR UPDATE ON books
    FOR EACH ROW EXECUTE PROCEDURE update_book_search();;

