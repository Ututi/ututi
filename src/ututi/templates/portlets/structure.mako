<%inherit file="/portlets/base.mako"/>

<%def name="struct_info_portlet(location=None)">
  <%
     if location is None:
         location = c.location
  %>

  <%self:portlet id="location_info_portlet">
    <%def name="header()">
      %if location.parent is None:
        <a ${h.trackEvent(location, 'home', 'portlet_header')} href="${location.url()}" title="${location.title}">${_('University information')}</a>
      %else:
        <a ${h.trackEvent(location, 'home', 'portlet_header')} href="${location.url()}" title="${location.title}">${_('Faculty information')}</a>
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
    <br class="clear-left" />
    <div id="location-stats">
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

<%def name="struct_groups_portlet(location=None)">
  <%
     if location is None:
         location = c.location
  %>
  <%self:portlet id="group_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Latest groups')}
    </%def>
    <%
       groups = location.latest_groups()
    %>
    % if not groups:
      ${_('There are no groups yet.')}
    %else:
    <ul>
      % for group in groups:
      <li>
        <div class="group-listing-item">
          %if group.logo is not None:
            <img class="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=25, height=25)}" alt="logo" />
          %else:
            ${h.image('/images/details/icon_group_25x25.png', alt='logo', class_='group-logo')|n}
          %endif
            <a href="${group.url()}">${group.title}</a>
            (${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count = len(group.members))})
            <br class="clear-left"/>
        </div>
      </li>
      % endfor
    </ul>
    %endif
    <div class="footer">
      ${h.link_to(_('All groups'), location.url(obj_type='group'), class_="more")}
      <span>
        ${h.button_to(_('Create group'), url(controller='group', action='add'))}
        ${h.image('/images/details/icon_question.png', alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'), class_='tooltip')|n}
      </span>
    </div>

  </%self:portlet>
</%def>
