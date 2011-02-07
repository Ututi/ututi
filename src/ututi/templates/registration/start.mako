<%inherit file="/base.mako" />

<h1>${_("Registration to Ututi")}</h1>

<form id="registration_form" method="POST" action="${url(controller='registration', action='start')}">
  ${h.input_line('email', _("Enter your email here:"))}
  ${h.input_hidden('location')}
  ${h.input_submit(_('Register'))}
</form>
