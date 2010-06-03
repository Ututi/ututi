<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>


<%def name="pagetitle()">
${_('What have I been doing?')}
</%def>
% if c.events:
  <ul id="event_list">
    % for event in c.events:
    <li>
      ${event.render()|n} <span class="event_time">(${event.when()})</span>
    </li>
    % endfor
  </ul>
% else:
  ${_("You haven't contributed much, have you?")}
% endif

