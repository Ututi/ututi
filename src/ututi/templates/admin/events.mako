<%inherit file="/admin/base.mako" />

<%def name="title()">
  Events
</%def>

<h1>${_('Events')}</h1>

%if c.events:
  <ul id="event_list">
  % for event in c.events:
  <li>
    ${event.render()|n} <span class="event_time">(${event.when()})</span>
  </li>
  % endfor
  </ul>
%endif
