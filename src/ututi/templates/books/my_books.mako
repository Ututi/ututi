<%inherit file="/books/base.mako" />
<%namespace name="books" file="/books/index.mako" />

<div class="my-books-content">
  <% owned_books_number = len(c.books) %>
  <span class="user-name">${c.user.fullname}:</span> <span class="orange">${_('Books added')}:</span> <span class="owned-books-number">${owned_books_number}</span>
  <h1>${_('My books')}: ${owned_books_number}</h1>
  %if c.books is not None and c.books != "":
  %for book in c.books:
  <%books:book_information book="${book}" can_edit="True" />
  %endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
  %else:
  ${_("You haven't added any books yet.")}
  %endif
</div>
