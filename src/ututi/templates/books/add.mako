<%inherit file="/books/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New book')}
</%def>

<a class="back-link" href="${url(controller='books', action='index')}">${_('back to catalog')}</a>
<h1>${_('New book')}</h1>


<%def name="head_tags()">
<%newlocationtag:head_tags />
</%def>

<%def name="book_logo_field()">
<form:error name="book_logo_upload" />
<label>
  <span class="labelText">${_('Book Cover')}</span>
  <input type="file" name="logo" id="book_logo_upload" class="line"/>
</label>
</%def>


<%def name="form(action)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<form method="post" action="${action}"
     id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
  <div class="book-logo">
    ${self.book_logo_field()}
  </div>
  <div class="basic-book-info">
    ${h.input_line('title', _('Title'))}
    ${h.input_line('author', _('Author'))}
    <select name="book_department">
      <option value="university">${_('University')}</option>
      <option value="school">${_('School')}</option>
      <option value="other">${_('Other')}</option>
    </select>
    ${h.input_area('description', _('Brief description of the book'))}
  </div>
  <div id="university_fields">
    ${location_widget(2)}
    ${h.input_line('subject', _('Course'))}
    <input type="checkbox" name="show_phone" value="True" /> ${_('Show my phone number')}
  </div>
  <div class="book-transfer-info">
    ${h.input_line('price', _('Price'))}
    <select name="city">
      %for city in c.cities:
      <option value="${city.name}">${c.city.name)}</option>
      %endfor
    </select>
    ${h.input_line('City', _('City'))}
  </div>
  <br />
  <div>
    ${h.input_submit(_('Save'))}
  </div>
  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='books', action='create')}"/>
