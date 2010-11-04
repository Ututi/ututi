CREATE TABLE books (
       id bigserial NOT NULL,
       title varchar(100) NOT NULL,
       description text,
       author varchar(100),
       year date,
       publisher varchar(100),
       pages_number int,
       location varchar(100),
       price float NOT NULL,
       cover bytea DEFAULT NULL,
       owner_id int8 NOT NULL REFERENCES users(id),
       show_phone boolean DEFAULT TRUE,
       PRIMARY KEY (id)
);;
