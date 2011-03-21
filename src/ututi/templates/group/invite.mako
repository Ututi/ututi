<%inherit file="/group/base.mako" />

<%def name="title()">
  ${_('Invite friends to %s') % c.group.title}
</%def>

%if c.has_facebook:

  <fb:serverFbml width="500">
    <script type="text/fbml">
      <fb:fbml>
        <fb:request-form action="${c.group.url(action='invite_fb', qualified=True)}"
                         method="POST"
                         invite="true"
                         type="Ututi"
                         content="${_('Join our group <a href="%s">%s</a> in Ututi, '
                                      'a system for exchanging study materials and information.') % \
                                      (c.group.url(qualified=True), c.group.title)}
                         <fb:req-choice url='${url(controller='registration',
                                                   action='start_fb',
                                                   path='/'.join(c.group.location.path),
                                                   qualified=True)}' label='${_('Join group')}' />
          ">
          <fb:multi-friend-selector max="20" actiontext="${_('Invite your friends to Ututi!')}"
                                    showborder="true" rows="5" cols="3" exclude_ids="${c.exclude_ids}">
        </fb:request-form>
      </fb:fbml>
    </script>
  </fb:serverFbml>

%else:
  <p>
    ${_("You have to log in to Facebook in order to use this invitation form.")}
  </p>

  <fb:login-button perms="email" onlogin="show_loading_message(); window.location = '${c.group.url(action='invite_fb')}'">
    ${_('Connect')}
  </fb:login-button>
%endif
