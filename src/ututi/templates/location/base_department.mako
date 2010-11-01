<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/portlets/school.mako" import="*"/>
<%namespace file="/location/base_university.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
  ${school_members_portlet(_("Faculty's members"))}
  ${struct_groups_portlet()}
</div>
</%def>

<%def name="title()">
  ${c.location.parent.title_short} ${c.location.title} - ${_('subjects list')}
</%def>

${location_title()}
${tabs()}

${next.body()}
