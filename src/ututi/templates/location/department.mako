<%inherit file="/location/base_department.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<%def name="body_class()">wall</%def>

<div class="tip">
${_('This is a list of all the recent events in the subjects and groups of this university.')}
</div>

%if c.events:
  ${wall.wall_entries(c.events)}
%else:
  ${_('Sorry, nothing new at the moment.')}
%endif
