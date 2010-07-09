<%inherit file="/ubase.mako" />

<%namespace file="/search/index.mako" import="search_form"/>

<%def name="head_tags()">
${parent.head_tags()}
<meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
</%def>

%if not request.params.get('register'):
  <div style="font-size: 20px">
    ${c.header}
  </div>

  <div id="login_message" class="${c.message_class or 'permission-denied'}">
    ${c.message|n}
    %if c.final_msg:
    <p>
      ${c.final_msg|n}
    </p>
    %endif
  </div>
%endif

<table id="login-screen">
  <td class="login-choice-box">
    <div class="login-note">
      ${_('Log in or register using your Google or Facebook account')}
    </div>
    <div id="federated-login-buttons">
      <a href="${url(controller='home', action='google_register', came_from=c.came_from)}" id="google-button">
        ${h.image('/img/google-logo.gif', alt='Log in using Google', class_='google-login')}
      </a>
      <br />
      ## We rely here on the fact that Facebook has been configured
      ## by the login widget in the page header.
      <fb:login-button perms="email"
          onlogin="show_loading_message(); window.location = '${url(controller='home', action='facebook_login', came_from=c.came_from)}'"
       >Connect</fb:login-button>
    </div>
  </td>

  <td class="login-choice-separator">
      ${_('or')}
  </td>

  <td class="login-choice-box">

    <div id="login-fields" ${"style='display: none'" if request.params.get('register') else ''}>
      <div class="login-note">
        ${_('Log in directly to Ututi')}
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

    <div id="register-fields" ${"style='display: none'" if not request.params.get('register') else ''}>
      <div class="login-note">
        ${_('Register as a new Ututi user')}
      </div>

      <form id="join_registration_form" method="post" action="${url(controller='home', action='register', register=True)}" class="fullForm">
        <fieldset>

        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif
        %if c.hash:
          <input type="hidden" name="hash" value="${c.hash}" />
        %endif

        ${h.input_line('fullname', _('Fullname'))}
         % if c.email:
          ${h.input_line('email', _('Email'), disabled="disabled", value=c.email)}
          <input  type="hidden" name="email" value="${c.email}" />
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
        <form:error name="agree"/>
        <label id="agreeWithTOC"><input type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
        <div>
          ${h.input_submit(_('Register'))}
        </div>

        </fieldset>
      </form>
   </div>

  </td>
</table>
