<%inherit file="/profile/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

<div class="tip">
${_('These are the files from the the subjects you or your group are watching.')}
</div>

% for n, subject in enumerate(c.user.watched_subjects):
  <%files:file_browser obj="${subject}" section_id="${n + 1}" collapsible="True"/>
% endfor

