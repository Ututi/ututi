<%inherit file="/base.mako" />

<h1>Registration to ${c.location.title}</h1>

% if c.registration_error:
<div class="error">${c.registration_error}</div>
% else:
<form id="registration_form" method="post" action="${url.current()}">
  %if c.came_from:
  <input type="hidden" name="came_from" value="${c.came_from}" />
  %endif

  ${h.input_line('email', _('Enter your email here:'))}
  ${h.input_submit(_('Register'))}
</form>
% endif
