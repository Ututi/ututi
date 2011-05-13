<%inherit file="/base.mako" />
<%namespace file="/portlets/structure.mako" import="location_logo_portlet, location_info_portlet,
                                                    location_admin_portlet, location_register_portlet,
                                                    location_register_teacher_portlet,
                                                    location_members_portlet, location_groups_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet, about_ututi_portlet,
                                                    navigation_portlet, create_network_portlet" />
<%namespace file="/elements.mako" import="tabs"/>

<%def name="portlets()">
%if c.user is not None:
  ${location_logo_portlet()}
  ${navigation_portlet(c.menu_items, c.current_menu_item)}
  ${location_admin_portlet()}
  ${location_info_portlet()}
  ${location_register_teacher_portlet()}
  ${share_portlet(c.location)}
  ${location_members_portlet(count=6)}
  ${location_groups_portlet()}
%else:
  ${location_logo_portlet()}
  ${location_register_portlet()}
  ${location_register_teacher_portlet()}
  ${navigation_portlet(c.menu_items, c.current_menu_item)}
  ${location_info_portlet()}
  ${about_ututi_portlet()}
  ${create_network_portlet()}
%endif
</%def>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${c.location.title}
</%def>


<h1 class="page-title ${'underline' if c.current_menu_item!='about' else ''}">
  ${self.pagetitle()}
</h1>

${next.body()}
