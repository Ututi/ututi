<%inherit file="/base.mako" />
<%namespace file="/portlets/group.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_forum_portlet()}
  ${group_files_portlet()}
  ${group_watched_subjects_portlet()}
  ${group_members_portlet()}
</div>
</%def>

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
