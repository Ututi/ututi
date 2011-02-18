<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("University information")}</%def>

<%def name="css()">
  ${parent.css()}
  form .textField input,
  form span.helpText {
    width: 300px;
  }
  form button.submit {
    margin-top: 35px;
  }
</%def>

<form id="university-create-form"
      action="${c.registration.url(action='university_create')}"
      enctype="multipart/form-data"
      method="POST">

  ${h.input_line('title', _("Full University title:"))}
  ${h.select_line('country', _("Country:"), c.countries)}
  ${h.input_line('site_url', _("University website:"))}

  <label for="logo-field">
    <span class="labelText">${_("University logo:")}</span>
    <input type="file" name="logo" id="logo-field" />
    <form:error name="logo" /> <!-- formencode errors container -->
  </label>

  ${h.select_radio('member_policy', _("Accessibility:"), c.policies)}

  <label for="allowed-emails">
    <span class="labelText">${_("Allowed emails:")}</span>
    <input type="text" name="allowed_emails" id="allowed-emails" />
    <input type="text" name="allowed_emails" id="allowed-emails" />
    <input type="text" name="allowed_emails" id="allowed-emails" />
    <form:error name="allowed_emails" /> <!-- formencode errors container -->
  </label>

  ${h.input_submit(_("Next"))}
</form>

