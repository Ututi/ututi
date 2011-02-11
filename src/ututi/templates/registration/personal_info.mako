<%inherit file="/registration/base.mako" />

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
      action="${url(controller='registration', action='personal_info', hash=c.registration.hash)}"
      method="POST">

  ${h.input_line('fullname', _("Full name:"))}
  ${h.input_psw('password', _("Password:"),
    help_text=_("Password must contain at least 5 characters."))}

  <div class="formField">
      <span class="labelText">${_("Link Google or Facebook")}</span>
      <div id="google-and-facebook-buttons">
        %if not c.registration.openid:
          <a id="google-link-button" href="${url(controller='registration', action='link_google', hash=c.registration.hash)}">
            ${h.image('/img/google-button.png', alt=_('Link Google'))}
          </a>
        %else:
          <a id="google-unlink-button" href="${url(controller='registration', action='unlink_google', hash=c.registration.hash)}">
            ${h.image('/img/google-button.png', alt=_('Unlink Google'))}
          </a>
        %endif
      </div>
      <div style="clear:both"></div>
  </div>

  ## TODO: FACEBOOK BUTTON
  ${h.input_submit(_("Next"))}
</form>

