<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="user_sidebar"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="pagetitle()">${_("Invite friends")}</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

<%def name="fb_invite_box()">
  %if c.has_facebook:
    <%
    location = c.user.location
    invitation_message = \
        h.literal(_('Join %(university_link)s social network in Ututi, '
                    'a system for exchanging study material and information.') % \
                     dict(university_link=h.link_to(location.title,
                                                    location.url(qualified=True))))
    %>
    <fb:serverFbml width="650">
      <script type="text/fbml">
        <fb:fbml>
          <fb:request-form action="${url(controller='profile', action='invite_friends_fb', qualified=True)}"
                           method="POST"
                           invite="true"
                           type="Ututi"
                           content="${_('Join our %(university_link)s social network in Ututi, '
                                        'a system for exchanging study material and information.') % \
                                        dict(university_link=h.link_to(location.title,
                                                                       location.url(qualified=True)))}
                           <fb:req-choice url='${url(controller='registration',
                                                     action='start_fb',
                                                     path='/'.join(location.path),
                                                     qualified=True)}' label='${_('Join Ututi')}' />
                           ">
            <fb:multi-friend-selector actiontext="${_('Invite your classmates to Ututi!')}"
                                      showborder="true" rows="4" cols="5" exclude_ids="${c.exclude_ids}">
          </fb:request-form>
        </fb:fbml>
      </script>
    </fb:serverFbml>
  %else:
    <p>
      ${_("You have to log in to Facebook in order to use this invitation form.")}
    </p>

    <fb:login-button perms="email" onlogin="show_loading_message(); window.location = '${url(controller='profile', action='invite_friends_fb')}'">
      ${_('Connect')}
    </fb:login-button>
  %endif
</%def>

${fb_invite_box()}
