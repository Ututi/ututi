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
          <label id="agreeWithTOC"><input class="checkbox" type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
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
    <div style="margin-top: 60px;">
      <div class="bullet">
        ${_('After registering, You will need to be confirmed as a teacher by our administrators.')}
      </div>
      <div class="bullet">
        ${_('Be sure to specify your university email address as this will make it easier for us to verify You as a teacher.')}
      </div>
      <div class="bullet">
        ${_('If You teach at more than one university, specify Your primary one: You will be able to specify Your information in more detail once You'\
        ' have registered.')}
      </div>
    </div>
  </td>
</table>
