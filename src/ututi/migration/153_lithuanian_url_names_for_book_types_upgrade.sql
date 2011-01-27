/* The following is not nice, but by this time we've all got the message:
 * don't fuck with books.
 */

update book_types set url_name = 'pratybu-sasiuviniai' where name = 'Pratybų sąsiuviniai';
update book_types set url_name = 'vadoveliai' where name = 'Vadovėliai';
update book_types set url_name = 'testai' where name = 'Testai';
update book_types set url_name = 'kita' where name = 'Kita';
update book_types set url_name = 'mokomoji-literatura' where name = 'Mokomoji literatūra';
update book_types set url_name = 'konspektai' where name = 'Konspektai';
