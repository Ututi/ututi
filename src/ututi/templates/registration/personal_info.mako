<%inherit file="/registration/base.mako" />

<h2>${_("Personal information")}</h2>

<p><strong>${c.registration.email}</strong></p>

<form id="personal-info-form"
      action="${url(controller='registration', action='personal_info', hash=c.registration.hash)}"
      method="POST">

  ${h.input_line('fullname', _("Full name:"))}
  ${h.input_line('password', _("Password:"))}

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
    </div>

  ## TODO: FACEBOOK BUTTON
  ${h.input_submit(_("Next"))}
</form>

