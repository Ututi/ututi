<%inherit file="/books/base.mako" />

<%def name="book_information(book)">
<div class="book-information">
  <div class="book-cover">
  </div>
  <div class="book-textual-info">
    <h3 class="book-title">${book.title}</h3>
  </div>
</div>
</%def>


<div>
%for book in c.books:
    ${book_information(book)}
%endfor
</div>

