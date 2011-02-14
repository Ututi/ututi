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

        %if not c.registration.facebook_id:
          <a id="fb-link-button" href="#link-facebook">
            ${h.image('/img/facebook-button.png', alt=_('Link Facebook'))}
          </a>
          <script>
            $(document).ready(function() {
              $('#fb-link-button').click(function() {
                  // attempt to login FB
                  FB.login(function(response) {
                      if (response.session && response.perms) {
                          // user is logged in and granted some permissions.
                          // perms is a comma separated list of granted permissions
                          window.location = '${url(controller='registration', action='link_facebook', hash=c.registration.hash)}';
                      }
                  }, {perms:'email'});

                  return false;
              });
            });
          </script>
        %else:
          <a id="fb-unlink-button" href="${url(controller='registration', action='unlink_facebook', hash=c.registration.hash)}">
            ${h.image('/img/facebook-button.png', alt=_('Unlink Facebook'))}
          </a>
        %endif
      </div>
      <span class="helpText" style="clear:both">${_("Click the buttons to link or unlink your profile with Google and/or Facebook")}</span>
  </div>

  ## TODO: FACEBOOK BUTTON
  ${h.input_submit(_("Next"))}
</form>

