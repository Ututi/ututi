<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  <meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
</%def>

%if getattr(c, 'show_warning', False) is not False:
  %if not c.show_registration or c.hash:
  <div style="font-size: 20px; padding-top: 7px">
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
%endif

<table id="login-screen">
  <td class="login-choice-box">
    <strong>
      ${h.literal(_("Ututi.xx has moved to %(ututi_com_link)s!") % \
          dict(ututi_com_link=h.link_to('Ututi.com', 'http://ututi.com')))}
    </strong>
    <div style="margin-top: 30px">
      <img src="/img/U-com.png" alt="Ututi.com" style="float: left; margin-right: 20px" />
      <p style="font-size: smaller; margin-bottom: 15px">- ${_("Join your university's social network;")}</p>
      <p style="font-size: smaller; margin-bottom: 15px">- ${_("Follow subjects that you study;")}</p>
      <p style="font-size: smaller; margin-bottom: 15px">- ${_("Communicate with academic community of your university.")}</p>
      <p style="text-align: right"><a class="forward-link" href="http://ututi.com">${_("Go to Ututi.com")}</a></p>
    </div>
  </td>

  <td class="login-choice-separator">
      ${_('or')}
  </td>

  <td class="login-choice-box">

    <div id="login-fields" ${"style='display: none'" if getattr(c, 'show_registration', False) else ''}>
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

    <div id="register-fields" ${"style='display: none'" if not getattr(c, 'show_registration') else ''}>
      <div class="login-note">
        ${_('Register as a new Ututi user')}
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
