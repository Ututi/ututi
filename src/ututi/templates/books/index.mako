<%inherit file="/books/base.mako" />

<%def name="book_information(book)">
<div class="book-information">
  <div class="book-cover">
  </div>
  <div class="book-textual-info">
    <h3 class="book-title">${book.title}</h3>
    <div>
      ${book.author}<br />
      ${h.ellipsis(book.description, 100)|n}
      %if book.location:
          <span class="book-location-title">${_('Location')}:</span>
          <span class="book-location-name"> ${book.location}</span>
          <br />
      %endif
      <span class="book-price-title">${_('Price')}:</span>
      <span class="book-location-name">
        %if book.price == 0:
        ${_('free')}
        %else:
        ${book.price} Lt
        %endif
      </span>
      <br />
      ${h.button_to(_("more"), url(controller="books", action="show", id=book.id))}
      %if c.user is book.owner:
      ${h.button_to(_("Edit"), url(controller="books", action="edit", id=book.id))}
      %endif
    </div>
  </div>
</div>
</%def>


<div>
%for book in c.books:
    ${book_information(book)}
%endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>

