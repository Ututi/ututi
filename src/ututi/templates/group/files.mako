<%inherit file="/group/base_wide.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<%files:file_browser obj="${c.group}" comment="${_('You can keep up to %s of private group files here (e.g. pictures)') % h.file_size(c.group.available_size)}" controls="['upload', 'folder', 'size', 'list']"/>

% for n, subject in enumerate(c.group.watched_subjects):
  <%files:file_browser obj="${subject}" section_id="${n + 1}" collapsible="True"/>
% endfor
<br/>
%if c.group.is_admin(c.user):

${h.button_to(_('Add more subjects'), c.group.url(action='subjects_watch'), method='get')}
%endif
