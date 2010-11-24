<%inherit file="/books/base.mako" />
<%namespace name="books" file="/books/index.mako" />

%if c.books is not None and c.books != "":
%for book in c.books:
<%books:book_information book="${book}" />
%endfor
<div id="pager">${c.books.pager(format='~3~') }</div>
%else:
${_("You haven't added any books yet.")}
%endif
