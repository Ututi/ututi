<%inherit file="/base.mako" />

<h1>${_("Registration to Ututi")}</h1>

<form id="registration_form" method="POST" action="${url(controller='registration', action='start', path='/'.join(c.location.path))}">
  ${h.input_line('email', _("Enter your email here:"))}
  ${h.input_submit(_('Register'))}
</form>
