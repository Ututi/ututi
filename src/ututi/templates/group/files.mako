<%inherit file="/group/home.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<h1>${_('Group Files')}</h1>

<%
    files.n = 0
%>

<%files:file_browser obj="${c.group}" />

% for subject in c.group.watched_subjects:
  <%files:file_browser obj="${subject}" />
% endfor
