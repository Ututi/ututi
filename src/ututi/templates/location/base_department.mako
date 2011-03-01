<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/structure.mako" import="location_logo_portlet, location_info_portlet,
                                                    location_admin_portlet, location_register_portlet,
                                                    location_members_portlet, struct_groups_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet" />
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/location/base_university.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="tabs"/>

<%def name="portlets()">
  ${location_logo_portlet()}
  ${location_admin_portlet()}
  ${location_info_portlet()}
  ${location_register_portlet()}
  ${share_portlet(c.location)}
  ${location_members_portlet(count=6)}
  ${struct_groups_portlet()}
</%def>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${c.location.title}
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${tabs()}

${next.body()}
