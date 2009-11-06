<%inherit file="/group/home.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<%files:file_browser obj="${c.group}" comment="${_('You can keep private group files here (e.g. pictures)')}"/>

% for n, subject in enumerate(c.group.watched_subjects):
  <%files:file_browser obj="${subject}" section_id="${n + 1}" collapsible="True"/>
% endfor
