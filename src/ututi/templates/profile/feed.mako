<%inherit file="/profile/base.mako" />
<%namespace name="wall" file="/sections/wall_snippets.mako" import="head_tags"/>
<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<div id='wall'>
<div class="tip">
${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
<a href="${url(controller='profile', action='wall_settings')}">${_('Edit shown updates.')}</a>
</div>

%if c.events:
  % for event in c.events:
    ${event.snippet()}
  % endfor
%else:
  ${_('Sorry, nothing new at the moment.')}
%endif
</div>
