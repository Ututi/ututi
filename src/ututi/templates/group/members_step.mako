<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/group/add.mako" import="path_steps"/>
<%namespace file="/group/members.mako" import="group_members_invite_section"/>
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<h1>${_('Add group members')}</h1>

${path_steps(1)}

${group_members_invite_section(wizard=True)}
