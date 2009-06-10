/* Create first user=admin and password=asdasd */

create table users (id bigserial not null, fullname char(100), password char(32), primary key (id));

insert into users (fullname, password) values ('Adminas Adminovič', '069edb446c4ec937e862bce38ee4c458');

/* Storing the emails of the users. */
create table emails (id int8 not null references users(id), email char(320), confirmed boolean default FALSE, primary key (email));

insert into emails (id, email) values (1, 'admin@ututi.lt');
