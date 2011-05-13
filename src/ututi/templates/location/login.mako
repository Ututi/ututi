<%inherit file="/base.mako" />

<h1>Login</h1>

<form id="login-form" method="post" action="${url.current()}">
    %if c.came_from:
    <input type="hidden" name="came_from" value="${c.came_from}" />
    %endif
    %if hasattr(c, 'login_error'):
    <div class="error">${c.login_error}</div>
    %endif
    ${h.input_line('login', _('Your email address'), value=request.params.get('login'))}
    ${h.input_psw('password', _('Password'))}

    <label id="rememberMe" for="remember"><input id="remember" name="remember" value="true" type="checkbox" class="checkbox"/> ${_('Keep me logged in on this computer')}</label>
    <div>
      <a href="${url(controller='home', action='pswrecovery')}">${_('Forgot password?')}</a>
    </div>

    <div>
    ${h.input_submit(_('Login'))}
    </div>
</form>
