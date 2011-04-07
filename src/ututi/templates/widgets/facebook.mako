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
        channelUrl: '${c.facebook_channel_url}'
      });
    </script>
  %endif
</%def>
