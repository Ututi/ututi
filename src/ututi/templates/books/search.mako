<%inherit file="/books/base.mako" />
<%namespace file="/books/index.mako" name="books" import="book_information"/>

<div>
  %for book in c.books:
  <%books:book_information book="${book}" />
  %endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>
