<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

%if c.cities:
  <table id="cities_list" style="width: 100%;">
    <tr>
      <th>${_('Book_Type')}</th>
    </tr>

    %for book_type in c.book_types:
    <tr>
      <td>${book_type.name}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_book_type", id=book_type.id)) }</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.book_types.pager(format='~3~') }</div>
%endif


<h1>${_('Book types')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='create_book_type')}"
      name="book_type_form" id="book_type_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
