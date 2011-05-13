<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

%if c.book_types:
  <table id="book_types_list" style="width: 100%;">
    <tr>
      <th>${_('Book_Type')}</th>
      <th>${_('URL name')}</th>
      <th>${_('Actions')}</th>
    </tr>

    %for book_type in c.book_types:
    <tr>
      <td>${book_type.name}</td>
      <td>${book_type.url_name}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_book_type", id=book_type.id)) }</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.book_types.pager(format='~3~') }</div>
%endif


<h1>${_('Book types')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='create_book_type')}"
      name="book_type_form" id="book_type_form" class="new-style-form">
  ${h.input_line('name', _('Name'))}
  ${h.input_line('url_name', _('URL name'),
                 help_text=_("Use only lowercase letters 'a' to 'z' and a dash '-'"))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
