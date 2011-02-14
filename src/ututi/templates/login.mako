<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  <meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
</%def>

<table id="login-screen">
  <td class="login-choice-box">
    <div class="login-note">
      ${_('Log in or register using your Google or Facebook account')}
    </div>
    <div id="federated-login-buttons">
      <a href="${url(controller='federation', action='google_register', came_from=c.came_from, invitation_hash=c.hash)}" id="google-button">
        ${h.image('/img/google-logo.gif', alt='Log in using Google', class_='google-login')}
      </a>
      <br />
      ## We rely here on the fact that Facebook has been configured
      ## by the login widget in the page header.
      <fb:login-button perms="email"
          onlogin="show_loading_message(); window.location = '${url(controller='federation', action='facebook_login', came_from=c.came_from, invitation_hash=c.hash)}'"
       >${_('Connect')}</fb:login-button>
    </div>
  </td>

  <td class="login-choice-separator">
      ${_('or')}
  </td>

  <td class="login-choice-box">

    <div id="login-fields" ${"style='display: none'" if getattr(c, 'show_registration', False) else ''}>
      <div class="login-note">
        ${_('Log in directly to TeamMate')}
      </div>

      <form id="join_login_form" method="post" action="${url(controller='home', action='join_login')}" class="fullForm">
        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif
        %if c.login_error:
          <div class="error">${c.login_error}</div>
        %endif
        ${h.input_line('login_username', _('Your email address'), value=request.params.get('login'))}
        ${h.input_psw('login_password', _('Password'))}
        <div class="floatright" style="padding-right: 2em">
          ${h.input_submit(_('Login'))}
        </div>
      </form>

      <div style="padding-bottom: 2em; padding-top: 5px; padding-right: 33px" class="floatright clear-right">
         <a href="${url(controller='home', action='pswrecovery')}">${_('Forgotten password?')}</a>
      </div>

      <div style="border-top: 2px solid #eae7e7; margin: 1em;
        padding-top: 5px; padding-left: 1em; margin-right: 3em" class="clear-right">
          ${_('First time here?')}
          <a href="#" onclick="$('#login-fields').hide(); $('#register-fields').show()"
            >${_('Register!')}</a>
      </div>
    </div>

    <div id="register-fields" ${"style='display: none'" if not getattr(c, 'show_registration', False) else ''}>
      <div class="login-note">
        ${_('Register as a new TeamMate user')}
      </div>

      <form id="join_registration_form" method="post" action="${url.current(action='register')}" class="fullForm">
        <fieldset>

        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif

        ${h.input_line('fullname', _('Full name'))}
        % if c.email:
          ${h.input_line('email', _('Email'), disabled="disabled", value=c.email)}
          <input type="hidden" name="email" value="${c.email}" />
        % else:
          ${h.input_line('email', _('Email'))}
        % endif
        %if c.gg_enabled:
          ${h.input_line('gadugadu', _('Gadu gadu'))}
        %else:
         <input type="hidden" id="gadugadu" name="gadugadu"/>
        %endif

         ${h.input_psw('new_password', _('Password'))}
         ${h.input_psw('repeat_password', _('Repeat password'))}
        <label id="agreeWithTOC"><input class="checkbox" type="checkbox" name="agree" checked="checked" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
        <form:error name="agree"/>
        <div>
          ${h.input_submit(_('Register'))}
        </div>

        </fieldset>
      </form>
   </div>

  </td>
</table>
