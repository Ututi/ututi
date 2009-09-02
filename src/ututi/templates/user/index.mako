<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${user_information_portlet(user=c.user_info, full=False, title=_('Member information'))}
  ${user_groups_portlet(user=c.user_info, title=_("Member's groups"), full=False)}

</div>
</%def>



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
