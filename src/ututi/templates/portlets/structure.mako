<%inherit file="/portlets/base.mako"/>

<%def name="struct_info_portlet(location=None)">
  <%
     if location is None:
         location = c.location
  %>

  <%self:portlet id="location_info_portlet">
    <%def name="header()">
      %if location.parent is None:
        <a ${h.trackEvent(location, 'home', 'portlet_header')|n} href="${location.url()}" title="${location.title}">${_('University information')}</a>
      %else:
        <a ${h.trackEvent(location, 'home', 'portlet_header')|n} href="${location.url()}" title="${location.title}">${_('Faculty information')}</a>
      %endif
    </%def>
    %if location.logo is not None:
      <img class="portlet-logo" id="structure-logo" src="${url(controller='structure', action='logo', id=location.id, width=70)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${location.title}</h4>
      %if location.site_url is not None:
        <span class="small"><a href="${location.site_url}" title="${location.title}">${location.site_url}</a></span>
      %endif
    </div>
    <div id="location-stats" class="clear-left">
      <span>
        <%
           cnt = location.count('subject')
        %>
        ${ungettext("%(count)s <em>subject</em>", "%(count)s <em>subjects</em>", cnt) % dict(count = cnt)|n}
      </span>
      <span>
        <%
           cnt = location.count('group')
        %>
        ${ungettext("%(count)s <em>group</em>", "%(count)s <em>groups</em>", cnt) % dict(count = cnt)|n}
      </span>
      <span>
        <%
           cnt = location.count('file')
        %>
        ${ungettext("%(count)s <em>file</em>", "%(count)s <em>files</em>", cnt) % dict(count = cnt)|n}
      </span>
    </div>
    <div class="footer">
      %if h.check_crowds(['moderator']):
        <a class="more" href="${location.url(action='edit')}" title="${_('Edit')}">${_('Edit')}</a>
      %endif
    </div>
  </%self:portlet>
</%def>
