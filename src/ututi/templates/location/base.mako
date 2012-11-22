<%inherit file="/base.mako" />
<%namespace file="/portlets/structure.mako" import="location_logo_portlet, location_info_portlet,
                                                    location_admin_portlet, location_register_portlet,
                                                    location_register_teacher_portlet,
                                                    location_dont_study_here_portlet,
                                                    location_members_portlet, location_groups_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet, about_ututi_portlet,
                                                    navigation_portlet, create_network_portlet" />
<%namespace file="/elements.mako" import="tabs"/>

<%def name="portlets()">
%if c.user is not None:
  ${location_logo_portlet()}
  ${location_admin_portlet()}
  ${navigation_portlet(c.menu_items, c.current_menu_item)}
  ${location_register_teacher_portlet()}
  ${location_info_portlet()}
%else:
  ${location_logo_portlet()}
  ${navigation_portlet(c.menu_items, c.current_menu_item)}
  ${location_dont_study_here_portlet()}
  ##${location_register_portlet()}
  ##${location_register_teacher_portlet()}
  ##${about_ututi_portlet()}
  ##${create_network_portlet()}
%endif
</%def>

<%def name="portlets_secondary()">
%if c.user is not None:
  ${share_portlet(c.location)}
  ${location_members_portlet(count=6)}
  ${location_groups_portlet()}
%endif
</%def>


<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${c.location.title}
</%def>

<%def name="css()">
  ${parent.css()}

  h1.page-title {
    margin-bottom: 2px; /* means we show breadcrumbs below */
  }

  h1.page-title.underline {
    margin-bottom: 15px; /* reset bottom margin */
  }

  ul#breadcrumbs {
    margin-bottom: 20px;
    font-size: 14px;
  }

  ul#breadcrumbs > li {
    display: inline;
    margin-right: 2px;
    padding-left: 12px;
    background: url("${url('/img/icons.com/arrow_right.png')}") no-repeat left center;
  }
  ul#breadcrumbs > li.first {
    padding-left: 0;
    background: none;
  }
</%def>

<%def name="breadcrumbs()">
<%doc>Only show breadcrumbs if we're not at root and not in a sub-department.</%doc>
%if c.location.parent or hasattr(c, 'subdepartment'):
<ul id="breadcrumbs">
  %for n, crumb in enumerate(c.breadcrumbs, 1):
    <li class="${'first' if n == 1 else ''}">
      <a href="${crumb['link']}">${crumb['full_title']}</a>
    </li>
  %endfor
</ul>
%endif
</%def>

<%def name="pageheader()">
  <% breadcrumbs_block = capture(self.breadcrumbs).strip() %>
  <h1 class="page-title ${'underline' if not breadcrumbs_block else ''}" >
    ${self.pagetitle()}
  </h1>
  ${h.literal(breadcrumbs_block)}
</%def>

${self.pageheader()}
%if not c.notabs:
${tabs()}
%endif

${next.body()}
