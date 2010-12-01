<%inherit file="/profile/edit.mako" />

<%def name="pagetitle()">
${_('Change password')}
</%def>

<form method="post" action="${url(controller='profile', action='password')}" id="change_password_form" class="fullForm">
  <fieldset>
  ${h.input_psw('password', _('Current password'))}
  ${h.input_psw('new_password', _('New password'))}
  ${h.input_psw('repeat_password', _('Repeat the new password'))}
  ${h.input_submit(_('Change password'), class_='btnMedium')}
  </fieldset>
</form>
