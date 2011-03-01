<%inherit file="/portlets/base.mako" />
<%namespace file="/portlets/universal.mako" import="user_box" />

<%def name="location_logo_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if location.has_logo():
  <%self:portlet id="location-logo-portlet">
    <div class="logo-container">
      <img src="${url(controller='structure', action='logo', id=location.id, width=140)}" alt="${location.title}" />
    </div>
  </%self:portlet>
  %endif
</%def>

<%def name="location_info_portlet(location=None)">
  <% if location is None: location = c.location %>
  <%self:portlet id="location-info-portlet">
    <%def name="header()">
      ${_("Info:")}
    </%def>
    <ul class="icon-list">
      %if location.site_url is not None:
      <li class="icon-contact">
        <a href="${location.site_url}">${location.site_url}</a>
      </li>
      %endif
      <li class="icon-subject">
        <% cnt = h.location_count(location.id, 'subject') %>
        ${ungettext("%(count)s Subject", "%(count)s Subjects", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-group">
        <% cnt = h.location_count(location.id, 'group') %>
        ${ungettext("%(count)s Group", "%(count)s Groups", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-user member-count">
        <% cnt = location.member_count() %>
        ${ungettext("%(count)s Member", "%(count)s Members", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-file">
        <% cnt = h.location_count(location.id, 'file') %>
        ${ungettext("%(count)s File", "%(count)s Files", cnt) % dict(count = cnt)}
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="location_admin_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if h.check_crowds(['moderator']):
    <%self:portlet id="location-admin-portlet">
      <%def name="header()">
        ${_("Administration:")}
      </%def>
      <a href="${location.url(action='edit')}">${_('Edit information')}</a>
    </%self:portlet>
  %endif
</%def>

<%def name="location_register_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if c.user is None:
    <%self:portlet id="location-register-portlet">
      ${h.button_to(_("I study here"),
                    url('start_registration_with_location',
                        path='/'.join(location.path)),
                    id='i-study-here-button',
                    class_='dark')}
    </%self:portlet>
  %endif
</%def>

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
    %if c.user is None:
    ${h.button_to(_("Register"), url('start_registration_with_location', path='/'.join(location.path)))}
    %endif
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
      ${h.link_to(_('Create group'), url(controller='group', action='create_academic'), method='GET')}
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


<%def name="user_logo_link(user, style=None)">
<div class="user-logo-link"
%if style is not None:
     style = ${style}
%endif
>
  <div class="user-logo">
    <a href="${url(controller="user", action="index", id=user.id)}"
       title="${user.fullname}">
      %if user.logo is not None:
      <img src="${url(controller='user', action='logo', id=user.id, width=45, height=45)}" alt="logo" />
      %else:
      ${h.image('/img/avatar-light-small.png', alt='logo')}
      %endif
    </a>
  </div>
  <div>
    <a href="${url(controller="user", action="index", id=user.id)}" title="${user.fullname}" class="link-to-user-profile">
      ${h.wraped_text(user.fullname, 10)|n}
    </a>
  </div>
</div>
</%def>

<%def name="location_members_portlet(location=None, count=None)">
  <%
  if location is None: location = c.location
  if count is None: count = 6
  members = location.get_members(count)
  total = location.member_count()
  %>
  %if members:
    ${user_box(_("Members:"), members, 'location-members-portlet')}
  %endif
</%def>
