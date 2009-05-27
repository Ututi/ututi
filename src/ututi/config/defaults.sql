/* Create first user=admin and password=asdasd */
create table users (id bigserial not null, name char(20), password char(40), PRIMARY KEY (id));
--- drop table users;

INSERT INTO users (id, name, password) VALUES (1, 'admin', '85136c79cbf9fe36bb9d05d0639c70c265c18d37');
