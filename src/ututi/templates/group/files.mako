<%inherit file="/group/home.mako" />
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/portlets/group.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_changes_portlet()}
</div>
</%def>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<h1>${_('Group Files')}</h1>
<br />

<%files:file_browser obj="${c.group}" />

% for n, subject in enumerate(c.group.watched_subjects):
  <%files:file_browser obj="${subject}" section_id="${n + 1}" collapsible="True"/>
% endfor
