<%inherit file="/base.mako" />
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="head_tags()">
  ${parent.head_tags()}
  <meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">plain</%def>

<%def name="css()">
  ${parent.css()}
  #login-box {
      margin-top: 40px;
  }
  #sign-up-link {
      height: 14px;
      padding-top: 10px;
      margin-bottom: -24px;
      text-align: right;
  }
  #login-choice-left {
      width: 50%;
      float: left;
  }
  #login-choice-right {
      width: 45%;
      float: right;
      text-align: center;
  }
  #login-choice-right .button {
      margin: 20px 0;
  }
  #login-or-remind {
      width: 300px;
  }
  #psw-remind-link {
      float: right;
      line-height: 20px;
  }
</%def>

<div id="sign-up-link">
  ${_("New in VUtuti?")}
  <a href="${url('frontpage')}">
    ${_("Sign in with your university email")}
  </a>
</div>

<h1 class="page-title underline">${_("Login")}</h1>

%if hasattr(c, 'header'):
  <p> <strong> ${c.header} </strong> ${h.literal(c.message)} </p>
%endif

<div class="clearfix" id="login-box">
  <div id="login-choice-left">
    <form id="login-form" method="post" action="${url(controller='home', action='login')}">
      %if c.came_from:
        <input type="hidden" name="came_from" value="${c.came_from}" />
      %endif
      ${h.input_line('username', _('Email address:'))}
      ${h.input_psw('password', _('Password:'))}
      %if hasattr(c, 'locations'):
        ${h.select_line('location', _('Select network:'), c.locations, [c.selected_location])}
      %endif
      <input id="remember" type="checkbox" name="remember" />
      <label for="remember-me" class="notice">
        ${_('Keep me logged in on this computer')}
      </label>
      <div class="clearfix" id="login-or-remind">
        <div id="psw-remind-link">
          <a href="${url(controller='home', action='pswrecovery')}"> ${_('Forgot password?')} </a>
        </div>
        ${h.input_submit(_('Login'))}
      </div>
    </form>
  </div>
</div>
