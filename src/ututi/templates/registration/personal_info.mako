<%inherit file="/registration/base.mako" />
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="pagetitle()">${_("Personal information")}</%def>

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

<p><strong>${c.registration.email}</strong></p>

<form id="personal-info-form"
      action="${c.registration.url(action='personal_info')}"
      method="POST">

  ${h.input_line('fullname', _("Full name:"))}
  ${h.input_psw('password', _("Password:"),
    help_text=_("Password must contain at least 5 characters"))}

  ${h.input_submit(_("Next"))}
</form>

