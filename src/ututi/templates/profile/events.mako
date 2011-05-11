<%inherit file="/profile/base.mako" />

<%def name="pagetitle()">
${_('What have I been doing?')}
</%def>

%if c.events:
  <ul id="event_list">
    %for event in c.events:
    <li>
      ${h.literal(event.render())} <span class="event_time">(${event.when()})</span>
    </li>
    %endfor
  </ul>
%else:
  ${_("You haven't contributed much, have you?")}
%endif

