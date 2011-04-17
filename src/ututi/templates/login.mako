<%inherit file="/ubase.mako" />
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
      border-right: 1px solid #888;
  }
  #login-choice-right {
      width: 45%;
      float: right;
      text-align: center;
  }
  #login-choice-right .button {
      margin: 20px 0;
  }
  #psw-remind-link {
      float: right;
      line-height: 20px;
  }
</%def>

<div id="sign-up-link">
  ${_("New in Ututi?")}
  <a href="${url('frontpage')}">
    ${_("Sign in with your university email")}
  </a>
</div>

<h1 class="page-title with-bottom-line">${_("Login")}</h1>

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
      <div class="clearfix" style="width: 210px">
        <div id="psw-remind-link">
          <a href="${url(controller='home', action='pswrecovery')}"> ${_('Forgot password?')} </a>
        </div>
        ${h.input_submit(_('Login'))}
      </div>
    </form>
  </div>

  <div id="login-choice-right">
    <strong>
      ${_('Or log in using Facebook or Google')}
    </strong>
    ## We rely here on the fact that Facebook has been configured
    ## by the login widget in the page header.
    <div class="button">
      <a id="facebook-login" href="#">
        ${h.image('/img/facebook-button.png', alt=_('Log in using Facebook'))}
      </a>
      ${init_facebook()}
      <script type="text/javascript">
        $(document).ready(function() {
          $('#facebook-login').click(function() {
              // attempt to login FB
              FB.login(function(response) {
                  if (response.session && response.perms) {
                      // user is logged in and granted some permissions.
                      // perms is a comma separated list of granted permissions
                      show_loading_message();
                      window.location = '${url(controller='federation', action='facebook_login', came_from=c.came_from)}';
                  }
              }, {perms:'email'});

              return false;
          });
        });
      </script>
    </div>
    <div class="button">
      <a href="${url(controller='federation', action='google_login', came_from=c.came_from, invitation_hash=c.hash)}">
        ${h.image('/img/google-button.png', alt=_('Log in using Google'))}
      </a>
    </div>
  </div>

</div>
