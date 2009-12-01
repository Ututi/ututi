<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<div class="display_selection">
  <a href="${url(controller='profile', action='home')}">${_('grouped')}</a>
  <a href="${url(controller='profile', action='feed')}" class="active">${_('ungrouped')}</a>
</div>

<div class="tip">
${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
</div>
<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
