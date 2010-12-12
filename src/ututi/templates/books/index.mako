<%inherit file="/books/base.mako" />

<%def name="book_information(book, can_edit = False)">
<div class="book-information">
  <div class="book-cover">
    %if book.logo is not None:
      <img src="${url(controller='books', action='logo', id=book.id, width=80, height=120)}" alt="${_('Book cover')}" />
    %else:
      <img src="${url('/images/books/default_book_icon.png')}" alt="${_('Book cover')}" />
    %endif
  </div>
  <div class="book-textual-info">
    <h3 class="book-title">${book.title}</h3>
    <div>
      <span class="book-author">${book.author}</span> <br />
      %if book.description is not None and book.description != "":
      <span class="book-description">${h.ellipsis(book.description, 100)|n}</span><br />
      %endif
      %if book.city:
          <span class="book-city-label">${_('City')}:</span>
          <span class="book-city-name"> ${book.city.name}</span>
          <br />
      %endif
      <span class="book-price-label">${_('Price')}:</span>
      <span class="book-price">
        ${book.price}
      </span>
      <br />
      %if can_edit:
        %if c.user is book.created:
        <div class="edit-button-container">
          ${h.button_to(_("Edit"), url(controller="books", action="edit", id=book.id))}
        </div>
        %endif
      %else:
      ${h.button_to(_("more"), url(controller="books", action="show", id=book.id))}
      %endif
    </div>
  </div>
</div>
</%def>

<%def name="ubooks_advicer()">
<div id="what_is_ubooks">
  <h3>${_("U-Books - what's that?")}</h3>
  <form class="button-right" method="post" action="${url('/books/add')}">
    <button class="btnMedium" type="submit" value="${_('Add book')}"><span>${_('Add book')}</span></button>
  </form>
  <ul class="ubooks_explanation">
    <li>${_("It's school books exchange / selling place.")}</li>
    <li>${_("It's place where you can get cheap stydy book.")}</li>
    <li>${_("It's place where you find new owner for you old good textbook.")}</li>
  </ul>
</div>
</%def>

<%self:ubooks_advicer />
<div>
<h1>${_('Newest books')}</h1>
%for book in c.books:
    ${book_information(book)}
%endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>

