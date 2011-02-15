<%inherit file="/ubase-nomenu.mako" />

<div id="fronpage-welcome">
  Welcome to team mate. Please <a href="/login">login</a>.
</div>

<form method="post" id="loginForm" action="${url('/login')}">

  <div id="federatedLogin">
    <div id="federatedLoginHint">${_('Connect using')}</div>
    <div id="login-buttons">
      <%
         if c.came_from:
           g_url = url(controller='federation', action='google_register', came_from=c.came_from)
           fb_url = url(controller='federation', action='facebook_login', came_from=c.came_from)
         else:
           g_url = url(controller='federation', action='google_register')
           fb_url = url(controller='federation', action='facebook_login')
      %>
      <a href="${g_url}" class="google-login"
          onclick="show_loading_message(); return true">
          ${h.image('/img/google.gif', alt=_('Log in using Google'))}
      </a>
      <fb:login-button size="icon" perms="email"
        onlogin="show_loading_message(); window.location = '${fb_url}'"
       >${_('Connect')}</fb:login-button>
    </div>
  </div>

  <fieldset>
    <input type="hidden" name="came_from" value="${c.came_from or request.url}" />
    <legend class="a11y">${_('Join!')}</legend>
    <label class="textField"><span class="overlay">${_('Email')}:</span><input type="text" name="login" value="${request.params.get('login')}"/><span class="edge"></span></label>
    <label class="textField"><span class="overlay">${_('Password')}</span><input type="password" name="password" /><span class="edge"></span></label>
    <button class="btn" type="submit" value="${_('Login')}"><span>${_('Login')}</span></button><br />
    <a href="${url(controller='home', action='pswrecovery')}">${_('Forgotten password?')}</a>
    <label id="rememberMe" for="remember"><input id="remember" name="remember" value="true" type="checkbox" class="checkbox"/> ${_('Remember me')}</label>
  </fieldset>
  <script type="text/javascript">
    $(document).ready(function(){$(".textField .overlay").labelOver('over');});
  </script>
</form>
