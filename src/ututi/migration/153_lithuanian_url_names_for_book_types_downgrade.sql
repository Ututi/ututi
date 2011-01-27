/* The following is not nice, but by this time we've all got the message:
 * don't fuck with books.
 */

update book_types set url_name = null where name = 'Pratybų sąsiuviniai';
update book_types set url_name = null where name = 'Vadovėliai';
update book_types set url_name = null where name = 'Testai';
update book_types set url_name = null where name = 'Kita';
update book_types set url_name = null where name = 'Mokomoji literatūra';
update book_types set url_name = null where name = 'Konspektai';
