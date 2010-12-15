<%inherit file="/ubase.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="head_tags()">
    ${parent.head_tags()}
    <%newlocationtag:head_tags />
</%def>

<table id="login-screen">
  <td class="login-choice-box">
    <div id="register-fields">
      <div class="login-note">
        ${_('Register as a teacher')}
      </div>

      <form id="teacher_registration_form" method="post" action="${url.current(action='register')}" class="fullForm">
        <fieldset>
          ${h.input_line('fullname', _('Full name'))}
          ${h.input_line('email', _('Email'))}
          ${h.input_psw('new_password', _('Password'))}
          ${h.input_psw('repeat_password', _('Repeat password'))}
          <div class="formField">
            ${location_widget(2, add_new=(c.tpl_lang=='pl'))}
          </div>
          ${h.input_line('position', _('Position'))}
          <label id="agreeWithTOC"><input class="checkbox" checked="checked" type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
          <form:error name="agree"/>
          <div style="margin-top: 10px;">
            ${h.input_submit(_('Register'))}
          </div>
        </fieldset>
      </form>
   </div>
  </td>
  <td class="login-choice-separator">
  </td>
  <td class="login-choice-box">
    <div class="login-note">
      ${_('Log in or register using your Google or Facebook account')}
    </div>
    <div id="federated-login-buttons">
      <a href="${url(controller='federation', action='google_register', u_type='teacher')}" id="google-button">
        ${h.image('/img/google-logo.gif', alt='Log in using Google', class_='google-login')}
      </a>
      <br />
      ## We rely here on the fact that Facebook has been configured
      ## by the login widget in the page header.
      <fb:login-button perms="email"
          onlogin="show_loading_message(); window.location = '${url(controller='federation', action='facebook_login', u_type='teacher')}'"
       >${_('Connect')}</fb:login-button>
    </div>

    <div style="margin-top: 30px;">
      <div class="bullet">
        ${_('Be patient')}
        <div class="tip">
          ${_('After registering, You will need to be confirmed as a teacher by our administrators.')}
        </div>
      </div>
      <div class="bullet">
        ${_('University email')}
        <div class="tip">
          ${_('Specify your university email address - this will make it easier to verify You as a teacher.')}
        </div>
      </div>
      <div class="bullet">
        ${_('Several universities?')}
        <div class="tip">
          ${_('If You teach at more than one university, specify Your primary one: You will be able to specify Your information in more detail once You'\
          ' have registered.')}
        </div>
      </div>
    </div>
  </td>
</table>
