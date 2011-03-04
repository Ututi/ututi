<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("Invite friends")}</%def>

<%def name="css()">
  ${parent.css()}
  #skip-link {
    float: right;
  }
</%def>

%if c.has_facebook:
  <%
  invitation_message = \
      h.literal(_('Join %(university_link)s social network in Ututi, '
                  'a system for exchanging study material and information.') % \
                   dict(university_link=h.link_to(c.registration.location.title,
                                                  c.registration.location.url(qualified=True))))
  %>
  <fb:serverFbml>
    <script type="text/fbml">
      <fb:fbml>
        <fb:request-form action="${c.registration.url(action='invite_friends_fb', qualified=True)}"
                         method="POST"
                         invite="true"
                         type="Ututi"
                         content="${_('Join our %(university_link)s social network in Ututi, '
                                      'a system for exchanging study material and information.') % \
                                      dict(university_link=h.link_to(c.registration.location.title,
                                                                     c.registration.location.url(qualified=True)))}
                         <fb:req-choice url='${url(controller='registration',
                                                   action='start_fb',
                                                   path='/'.join(c.registration.location.path),
                                                   qualified=True)}' label='${_('Join Ututi')}' />
                         ">
          <fb:multi-friend-selector actiontext="${_('Invite your classmates to Ututi!')}"
                                    showborder="true" rows="7" cols="6" exclude_ids="${c.exclude_ids}">
        </fb:request-form>
      </fb:fbml>
    </script>
  </fb:serverFbml>
%else:
  <p>
    ${_("You have to log in to Facebook in order to use this invitation form.")}
  </p>

  <fb:login-button perms="email" onlogin="show_loading_message(); window.location = '${c.registration.url(action='invite_friends_fb')}'">
    ${_('Connect')}
  </fb:login-button>
  <a id="skip-link" href="${c.registration.url(action='invite_friends')}">
    ${_("Skip")}
  </a>
%endif
