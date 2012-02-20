<%inherit file="/profile/settings_base.mako" />
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="css()">
  ${parent.css()}
  .left-right {
    margin-top: 20px;
  }
</%def>

<div class="left-right">

  <div class="left">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('Change password')}</h2>
      <p class="tip">
        ${_("To change your password, type your current password and repeat new password twice in the form below.")}
      </p>
    </div>
    <form method="post" action="${url(controller='profile', action='change_password')}" id="change-password-form" class="narrow">
      ${h.input_psw('password', _('Current password'))}
      ${h.input_psw('new_password', _('New password'))}
      ${h.input_psw('repeat_password', _('Repeat the new password'))}
      ${h.input_submit(_('Change password'))}
    </form>
    
    <div class="explanation-post-header" style="margin-top:30px">
      <h2>${_('Delete account')}</h2>
      <p class="tip">
        ${_("To delete your account, type your current password in the form below.")}
      </p>
    </div>
    <form method="post" action="${url(controller='profile', action='delete_my_account')}" id="delete-my-account-form" class="narrow">
      ${h.input_psw('passwordd', _('Current password'))}
      ${h.input_submit(_('Delete my account'),'delete_me_btn')}
    </form>
  </div>
  <div class="right">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('Recover password')}</h2>
      <p class="tip">
        ${_('In case you forgot your password, use the button below to recover it.')}
      </p>
    </div>
    ${h.button_to(_("Recover password"),
                  url(controller='profile', action='recover_password'),
                  method='GET', class_='dark')}

    <div class="explanation-post-header">
      <h2>${_('Link with Google and/or Facebook')}</h2>
      <p class="tip">
        ${_("You can log in to Ututi using your Google or Facebook account. "
            "Use buttons below to link or unlink these external accounts.")}
      </p>
    </div>

    <div id="google-and-facebook-buttons" class="clearfix">
      %if not c.user.openid:
        <a id="google-link-button" href="${url(controller='profile', action='link_google')}">
          ${h.image('/img/google-button.png', alt=_('Link Google'))}
        </a>
      %else:
        <a id="google-unlink-button" href="${url(controller='profile', action='unlink_google')}">
          ${h.image('/img/google-button.png', alt=_('Unlink Google'))}
        </a>
      %endif

      %if not c.user.facebook_id:
        <a id="fb-link-button" href="#link-facebook">
          ${h.image('/img/facebook-button.png', alt=_('Link Facebook'))}
        </a>
      %else:
        <a id="fb-unlink-button" href="${url(controller='profile', action='unlink_facebook')}">
          ${h.image('/img/facebook-button.png', alt=_('Unlink Facebook'))}
        </a>
      %endif
    </div>

    ${init_facebook()}
    <script>
      $(document).ready(function() {
        $('#fb-link-button').click(function() {
            // attempt to login FB
            FB.login(function(response) {
                if (response.authResponse) {
                    // user is logged in and granted some permissions.
                    // scope is a comma separated list of granted permissions
                    window.location = '${url(controller='profile', action='link_facebook')}';
                }
            }, {scope:'email'});

            return false;
        });
      });
    </script>
  </div>
</div>

