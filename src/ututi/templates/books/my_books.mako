<%inherit file="/books/base.mako" />

<div class="my-books-content">
  <span class="user-name">${c.user.fullname}:</span> <span class="orange">${_('Books added')}:</span> <span class="owned-books-number">${c.owned_books_number}</span>
  <h1>${_('My books')}: ${c.owned_books_number}</h1>
  %if c.active_books:
  %for book in c.active_books:
  <%self:book_information_long book="${book}" can_edit="True" />
  %endfor
  %else:
  ${_("You haven't added any books yet.")}
  %endif

  %for book in c.expired_books:
  <div class="book-information-expired" style="padding-bottom: 10px;">
    <h3 class="book-title" style="float:left;  font-size: 16px; color: #999; padding-left: 100px;">${book.title}</h3>
    <div style="float: right; padding-right: 20px;">
      ${h.link_to(_("Restore"), url(controller="books", action="restore_book", id=book.id))}
      <img src="${url('/images/books/restore.png')}" />
    </div>
  </div>
  <br style="clear: both;" />
  %endfor
</div>
