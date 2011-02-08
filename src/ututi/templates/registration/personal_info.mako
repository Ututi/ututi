<%inherit file="/base.mako" />

<h2>${_("Personal information")}</h2>

<p><strong>${c.registration.email}</strong></p>

<form id="personal-info-form"
      action="${url(controller='registration', action='personal_info', hash=c.registration.hash)}"
      method="POST">
  ${h.input_line('fullname', _("Full name:"))}
  ${h.input_line('password', _("Password:"))}
  <label>${_("Link Google or Facebook")}</label>
  ## GOOGLE AND FACEBOOK BUTTONS
  ${h.input_submit(_("Next"))}
</form>

