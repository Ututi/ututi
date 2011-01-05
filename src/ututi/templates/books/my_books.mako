<%inherit file="/books/base.mako" />
<%namespace name="books" file="/books/index.mako" />

<div class="my-books-content">
  <span class="user-name">${c.user.fullname}:</span> <span class="orange">${_('Books added')}:</span> <span class="owned-books-number">${c.owned_books_number}</span>
  <h1>${_('My books')}: ${c.owned_books_number}</h1>
  %if c.active_books:
  %for book in c.active_books:
  <%books:book_information book="${book}" can_edit="True" />
  ${h.button_to(_("Delete"), url(controller="books", action="delete", id=book.id), id_="delete_book_%s" % book.id)}
  %endfor
  %else:
  ${_("You haven't added any books yet.")}
  %endif

  %for book in c.expired_books:
  <div class="book-information expired-book">
    <div class="book-cover">
      %if book.logo is not None:
      <img src="${url(controller='books', action='logo', id=book.id, width=80, height=120)}" alt="${_('Book cover')}" />
      %else:
      <img src="${url('/images/books/default_book_icon.png')}" alt="${_('Book cover')}" />
      %endif
    </div>
    <div class="book-textual-info">
      <h3 class="book-title">${book.title}</h3>
      <div class="edit-button-container">
        ${h.button_to(_("Restore"), url(controller="books", action="restore_book", id=book.id), id_="restore_book_%s" % book.id)}
      </div>
    </div>
  </div>
  %endfor
</div>
