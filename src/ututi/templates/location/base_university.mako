<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/portlets/school.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="tabs"/>
<%namespace file="/anonymous_index.mako" import="universities_section"/>

<%def name="title()">
  ${c.location.title} (${c.location.title_short}) - ${_('department list')}
</%def>

<%def name="location_title()">
  %if c.location.logo is not None:
  <div class="title-with-logo">
    <img class="portlet-logo" id="structure-logo" src="${url(controller='structure', action='logo', id=c.location.id, width=70, height=70)}" alt="logo" />
  %else:
  <div>
  %endif
    <h1 class="pageTitle">${c.location.title}</h1>
  </div>
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
  ${school_members_portlet(_("School's members"))}
</div>
</%def>

${location_title()}
${universities_section(c.departments, c.location.url(), collapse=True, collapse_text=_('More departments'))}
${tabs()}

${next.body()}
