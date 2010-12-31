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
    <div style="height: 60px;">
      <h3 class="book-title">
        ${h.link_to(book.title, url(controller="books", action="show", id=book.id))}
      </h3>
      <span class="book-author">${book.author}</span>
    </div>
    <div>
      %if book.city:
          <span class="book-city-label">${_('City')}:</span>
          <span class="book-city-name"> ${book.city.name}</span>
          <br />
      %endif
      <span class="book-price-label">${_('Price')}:</span>
      <span class="book-price">
        ${book.price}
      </span>
    </div>
    <div class="book-action-container">
      %if can_edit:
        %if c.user is book.created:
        <div class="edit-button-container">
          ${h.link_to(_("Edit"), url(controller="books", action="edit", id=book.id))}
        </div>
        %endif
      %else:
      ## TRANSLATORS: translate this as a single word 'More'
      ${h.link_to(_("more_about_book"), url(controller="books", action="show", id=book.id))}
      %endif
    </div>
  </div>
</div>
</%def>

<%def name="list_of_books(books)">
%for n, book in enumerate(books):
    %if n and (n % 3 == 0):
      <hr />
    %endif
    ${book_information(book)}
%endfor
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
  <%self:list_of_books books="${c.books}" />
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>
