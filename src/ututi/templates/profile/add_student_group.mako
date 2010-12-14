<%inherit file="/profile/base.mako" />

<%def name="pagetitle()">
${_('Add a student group')}
</%def>

<form method="post" action="${url(controller='profile', action='add_student_group')}" id="student_group_form" class="fullForm">
  <fieldset>
  ${h.input_line('title', _('Title'))}
  ${h.input_line('email', _('Email address'))}
  ${h.input_submit(_('Save'), class_='btnMedium')}
  </fieldset>
</form>
