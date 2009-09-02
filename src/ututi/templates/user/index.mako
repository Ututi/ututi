<%inherit file="/base.mako" />

<%def name="title()">
  ${c.user_info.fullname}
</%def>

<h1>${_('Latest actions')}</h1>
% if c.events:
  <ul id="event_list">
    % for event in c.events:
    <li>
      ${event.render()|n} <span class="event_time">(${event.when()})</span>
    </li>
    % endfor
  </ul>
% else:
  ${_("Nothing yet.")}
% endif
