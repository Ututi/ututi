<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/wall.js')}
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<div id='wall'>
<div class="tip">
${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
<a href="${url(controller='profile', action='wall_settings')}">${_('Edit shown updates.')}</a>
</div>

% for event in c.events:
  ${event.snippet()}
% endfor
</div>
