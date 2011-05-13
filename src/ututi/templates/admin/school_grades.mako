<%inherit file="/base.mako" />

<h1>${_('School grades')}</h1>
<br />
%if c.school_grades:
  <table id="school_grades_list">
    <tr>
      <th>${_('School grade')}</th>
    </tr>

    %for school_grade in c.school_grades:
    <tr>
      <td>${school_grade.name}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_school_grade", id=school_grade.id)) }</td>
      <td>${h.link_to(_("Delete"), url(controller="admin", action="delete_school_grade", id=school_grade.id))}</td>
    </tr>
    %endfor
  </table>
%endif
<br />
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='create_school_grade')}"
      name="school_grade_form" id="school_grade_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>

