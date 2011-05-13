<%inherit file="/base.mako" />

<h1>${_('School grade')}: ${c.school_grade.name}</h1>

<h2>${_('Editing')}</h2>

<form method="post" action="${url(controller='admin', action='update_school_grade', id=c.school_grade.id)}"
      name="school_grade_form" id="school_grade_form" class="fullForm">

  <input type="hidden" name="id" value=""/>
  ${h.input_line('name', _('Name'))}
  <br />
  <div>
  ${h.input_submit(_('Edit'))}
  </div>
</form>

