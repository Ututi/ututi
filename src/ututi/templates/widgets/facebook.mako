<%def name="init_facebook()">
  <%doc>
  Init facebook. Should always be called before using FB widgets.
  Guards against double init by setting a marker to context object.
  </%doc>
  %if not getattr(c, '_facebook_was_init', False):
    <% c._facebook_was_init = True %>
    <div id="fb-root"></div>
    %if c.lang == 'lt':
    <script src="http://connect.facebook.net/lt_LT/all.js"></script>
    %elif c.lang == 'pl':
    <script src="http://connect.facebook.net/pl_PL/all.js"></script>
    %else:
    <script src="http://connect.facebook.net/en_US/all.js"></script>
    %endif
    <script>
      FB.init({
        appId: '${c.facebook_app_id}',
        status: true,
        cookie: true,
        xfbml: true,
        channelUrl: '${url(controller='home', action='fbchannel', qualified=True)}'
      });
    </script>
    <noscript>
      <p class="warning">
        ${_("Please have javascript enabled for Facebook functionality to work.")}
      </p>
    </noscript>
  %endif
</%def>

<%def name="invitation_box(title, action_url, message, label, choice_url, exclude_ids=[])">
  ${init_facebook()}
  <fb:serverFbml width="630">
    <script type="text/fbml">
      <fb:fbml>
        <fb:request-form action="${url(action_url, qualified=True)}" method="POST" invite="true" type="Ututi"
                         content="${message} <fb:req-choice url='${url(choice_url, qualified=True)}' label='${label}' /> ">
          <fb:multi-friend-selector max="20" actiontext="${title}"
                                    showborder="true" rows="5" cols="7" exclude_ids="${exclude_ids}">
        </fb:request-form>
      </fb:fbml>
    </script>
  </fb:serverFbml>
</%def>

<%def name="login_button(action_url=None, bind_account=True)">
  ${init_facebook()}
  <%
  action_url = action_url or url.current()
  if bind_account:
    action_url = url(controller='federation', action='facebook_bind_proxy', redirect_to=action_url)
  %>
  <fb:login-button perms="email" onlogin="show_loading_message(); window.location = '${action_url}'">
    ${_('Connect')}
  </fb:login-button>
</%def>

<%def name="login_js(action_url=None, bind_account=True)">
  ${init_facebook()}
  <%
  action_url = action_url or url.current()
  if bind_account:
    action_url = url(controller='federation', action='facebook_bind_proxy', redirect_to=action_url)
  %>
  <script type="text/javascript">
    $(document).ready(function() {
        show_loading_message();
        // attempt to login FB
        FB.login(function(response) {
            if (response.session && response.perms) {
                // user is logged in and granted some permissions.
                // perms is a comma separated list of granted permissions
                window.location = '${action_url}';
            }
        }, {perms:'email'});
    });
  </script>
</%def>
