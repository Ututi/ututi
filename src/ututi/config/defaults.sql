/* Create first user=admin and password=asdasd */
create table users (id bigserial not null, name char(20), password char(32), PRIMARY KEY (id));

INSERT INTO users (id, name, password) VALUES (1, 'admin', '069edb446c4ec937e862bce38ee4c458');
