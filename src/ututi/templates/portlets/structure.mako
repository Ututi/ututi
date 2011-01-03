<%inherit file="/portlets/base.mako"/>

<%def name="struct_info_portlet(location=None)">
  <%
     if location is None:
         location = c.location
  %>

  <%self:uportlet id="location_info_portlet" portlet_class="MyProfile">
    <%def name="header()">
      %if location.parent is None:
        <a ${h.trackEvent(location, 'home', 'portlet_header')} href="${location.url()}" title="${location.title}">${_('University information')}</a>
      %else:
        <a ${h.trackEvent(location, 'home', 'portlet_header')} href="${location.url()}" title="${location.title}">${_('Faculty information')}</a>
      %endif
    </%def>
    <div class="profile">
        <div class="floatleft avatar">
          %if location.logo is not None:
            <img class="portlet-logo" id="structure-logo" src="${url(controller='structure', action='logo', id=location.id, width=70, height=70)}" alt="logo" />
          %endif
        </div>
        <div class="floatleft personal-data uni-name">
            <div><h2 class="group-name">${location.title}</h2></div>
            %if location.site_url is not None:
            <div><a href="${location.site_url}">${location.site_url}</a></div>
            %endif
        </div>
        <div class="clear"></div>
    </div>
    <ul class="uni-info">
      <li>
        <%
           cnt = h.location_count(location.id, 'subject')
        %>
        ${ungettext("<span class='bold'>%(count)s</span> subject", "<span class='bold'>%(count)s</span> subjects", cnt) % dict(count = cnt)|n}
      </li>
      <li>
        <%
           cnt = h.location_count(location.id, 'group')
        %>
        ${ungettext("<span class='bold'>%(count)s</span> group", "<span class='bold'>%(count)s</span> groups", cnt) % dict(count = cnt)|n}
      </li>
      <li>
        <%
           cnt = h.location_count(location.id, 'file')
        %>
        ${ungettext("<span class='bold'>%(count)s</span> file", "<span class='bold'>%(count)s</span> files", cnt) % dict(count = cnt)|n}
      </li>

    </ul>
    %if h.check_crowds(['moderator']):
      <div class="right_arrow"><a href="${location.url(action='edit')}">${_('Edit')}</a></div>
    %endif
  </%self:uportlet>
</%def>

<%def name="struct_groups_portlet(location=None)">
  <%
     if location is None:
         location = c.location
  %>
  <%self:uportlet id="group_portlet">
    <%def name="header()">
      ${_('Latest groups')}
    </%def>
    <%
       groups = h.location_latest_groups(location.id, 5)
    %>
    % if not groups:
      ${_('There are no groups yet.')}
    %else:
    <ul class="group-listing">
      % for group in groups:
      <li>
        <div>
          %if group['logo'] is not None:
            <img class="group-logo" src="${url(controller='group', action='logo', id=group['group_id'], width=35, height=35)}" alt="logo" />
          %else:
            ${h.image('/images/details/icon_group_35x35.png', alt='logo', class_='group-logo')|n}
          %endif
            <span>
              <a href="${group['url']}" >${group['title']}</a>
              (${ungettext("%(count)s member", "%(count)s members", group['member_count']) % dict(count = group['member_count'])})
            </span>
            <br class="clear-left"/>
        </div>
      </li>
      % endfor
    </ul>
    %endif
    <div class="footer" style="margin-top: 10px">
      ${h.link_to(_('All groups'), location.url(obj_type='group'), class_="right_arrow floatright")}
      ${h.button_to(_('Create group'), url(controller='group', action='create_academic'))}
    </div>
  </%self:uportlet>

%if c.user is None:
<script type="text/javascript"><!--
google_ad_client = "pub-1809251984220343";
/* Universities portlet 300x250 */
google_ad_slot = "4000532165";
google_ad_width = 300;
google_ad_height = 250;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script> 
%endif


</%def>
