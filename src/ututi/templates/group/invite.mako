<%inherit file="/group/base.mako" />

<%def name="title()">
  ${_('Invite friends to %s') % c.group.title}
</%def>

<fb:serverFbml width="630">
  <script type="text/fbml">
    <fb:fbml>
      <fb:request-form action="${c.group.url(action='invite_fb', qualified=True)}"
                       method="POST" invite="true"
                       type="Ututi" content="${_('Join our group <a href="%s">%s</a> in Ututi, a system for exchanging study materials and information.') % (c.group.url(qualified=True), c.group.title)}
        <fb:req-choice url='${url(controller='home', action='index', qualified=True)}' label='${_('Join Ututi')}' />
                       ">
        <fb:multi-friend-selector max="20" actiontext="${_('Invite your friends to Ututi!')}"
                                  showborder="true" rows="5" cols="7" exclude_ids="">
      </fb:request-form>
    </fb:fbml>
  </script>
</fb:serverFbml>
