<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

%if c.science_types:
  <table id="science_types_list" style="width: 100%;">
    <tr>
      <th>${_('Science type')}</th>
      <th>${_('Book department')}</th>
    </tr>

    %for science_type in c.science_types:
    <tr>
      <td>${science_type.name}</td>
      <td>${_(science_type.book_department.title)}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_science_type", id=science_type.id)) }</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.science_types.pager(format='~3~') }</div>
%endif


<h1>${_('Science types')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='create_science_type')}"
      name="science_type_form" id="science_type_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  <label>${_('Book department')}: ${h.select('department', None, c.book_departments)}</label>
  <br />
  ${h.input_submit(_('Save'))}
</form>
