<%inherit file="/profile/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<div class="tip">
${_('These are the files from the the subjects you or your group are watching.')}
</div>

% for n, object in enumerate(c.user.watched_subjects):
  <%files:file_browser obj="${object}" section_id="${n}" collapsible="True"/>
% endfor
<%
   start = len(c.user.watched_subjects)
%>
% for n, object in enumerate(c.user.groups):
  <%files:file_browser obj="${object}" section_id="${n + start}" collapsible="True" title="${_('Private files of the group %s') % object.title}"/>
% endfor
