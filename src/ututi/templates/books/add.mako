<%inherit file="/books/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New book')}
</%def>

<a class="back-link" href="${url(controller='profile', action='search')}">${_('back to search')}</a>
<h1>${_('New book')}</h1>


<%def name="head_tags()">
<%newlocationtag:head_tags />
</%def>

<%def name="book_cover_field()">
  <form:error name="book_cover_upload" />
    <label>
      <span class="labelText">${_('Book Cover')}</span>
      <input type="file" name="cover" id="book_cover_upload" class="line"/>
  </label>
</%def>


<%def name="form(action, personal=False)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<form method="post" action="${action}"
     id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
  <div class="basic-book-info">
    ${h.input_line('title', _('Title'))}
    ${h.input_line('author', _('Author'))}
    <div class="form-field">
      <label for="description">${_('Brief description of the book')}</label>
      <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
    </div>
 </div>
  <div class="extra-book-info">
    ${h.input_line('publisher', _('Publisher'))}
    ${h.input_line('pages_number', _('Pages number'))}
    ${h.input_line('year', _('Book Year'))}
  </div>
  <div class="book-owner-info">
    ${location_widget(2)}
    ${h.input_line('subject', _('Course'))}
    <input type="checkbox" name="show_phone" value="True" /> ${_('Show my phone number')}
  </div>
  <div class="book-transfer-info">
    ${h.input_line('price', _('Price'))}
    ${h.input_line('location', _('Location'))}
  </div>

  ${self.book_cover_field()}
  <br class="clear-left"/>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget()}
  </div>
  <br />

<!--
  <div class="form-field check-field">
    <label for="watch_book">
      <input type="checkbox" name="watch_book" id="watch_book" value="watch"/>
      ${_('Start watching this book personally')}
    </label>
  </div>
-->
  <br />
  <div>

    ${h.input_submit(_('Save'))}
  </div>
  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='books', action='create')}" personal="True"/>
