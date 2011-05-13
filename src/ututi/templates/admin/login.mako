<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – Admin</title>
</%def>

<h1>Login as an admin</h1>
<form id="adminLoginForm" method="post" action="${url(controller='admin', action='join_login')}">
  ${h.input_line('login_username', _('Username'))}
  ${h.input_psw('login_password', _('Password'))}
  <br />
  <div>
    ${h.input_submit(_('Login'))}
  </div>
</form>
