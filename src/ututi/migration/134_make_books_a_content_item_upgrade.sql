drop table books;

CREATE TABLE books (
       id int8 references content_items(id),
       title varchar(100) NOT NULL,
       description text,
       author varchar(100),
       price varchar(250) DEFAULT '' NOT NULL,
       logo bytea DEFAULT NULL,
       city_id int8 DEFAULT NULL REFERENCES cities(id) on delete restrict,
       science_type_id int8 NOT NULL REFERENCES science_types(id) on delete restrict,
       type_id int8 NOT NULL REFERENCES book_types(id) on delete restrict,
       department_id int8 NOT NULL,
       school_grade_id int8 REFERENCES school_grades(id) on delete restrict,
       course varchar(100) default '',
       location_id int8 REFERENCES tags(id),
       owner_name varchar(50) DEFAULT '' NOT NULL,
       owner_phone varchar(50) DEFAULT '' NOT NULL,
       owner_email varchar(100) DEFAULT '' NOT NULL,
       valid_until timestamp not null default (now() at time zone 'UTC'),
       PRIMARY KEY (id)
);

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
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_book_search() RETURNS trigger AS $$
    BEGIN
      PERFORM update_book_worker(NEW);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_book_search AFTER INSERT OR UPDATE ON books
    FOR EACH ROW EXECUTE PROCEDURE update_book_search();
