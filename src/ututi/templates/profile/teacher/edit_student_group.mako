<%inherit file="/profile/base.mako" />

<%def name="pagetitle()">
${_('Edit a student group')}
</%def>

<form method="post" action="${url(controller='profile', action='edit_student_group', id=c.student_group.id)}" id="student_group_form" class="fullForm">
  <fieldset>
  ${h.input_line('title', _('Title'))}
  ${h.input_line('email', _('Email address'))}
  ${h.input_submit(_('Save'), class_='btnMedium')}
  </fieldset>
</form>
