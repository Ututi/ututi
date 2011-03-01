<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/portlets/structure.mako" import="location_logo_portlet, location_info_portlet,
                                                    location_admin_portlet, location_register_portlet,
                                                    location_members_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet" />
<%namespace file="/sections/content_snippets.mako" import="tabs"/>
<%namespace file="/anonymous_index.mako" import="universities_section"/>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${c.location.title}
</%def>

<%def name="portlets()">
  ${location_logo_portlet()}
  ${location_admin_portlet()}
  ${location_info_portlet()}
  ${location_register_portlet()}
  ${share_portlet(c.location)}
  ${location_members_portlet(count=6)}
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${universities_section(c.departments, c.location.url(), collapse=True, collapse_text=_('More departments'))}
${tabs()}

${next.body()}
