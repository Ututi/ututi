<%inherit file="/admin/base.mako" />

<%def name="title()">
  Events
</%def>

<h1>${_('Events')}</h1>



<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s event", "found %(count)s events", c.events.item_count) % dict(count = c.events.item_count)})</span>
  </h3>
  <ul id="event_list">
    %for event in c.events:
     <li>${event.render()|n} <span class="event_time">(${event.when()})</span></li>
    %endfor
  </ul>
  <div id="pager">${c.events.pager(format='~3~') }</div>
</div>
