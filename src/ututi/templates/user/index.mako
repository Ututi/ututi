<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="portlets()">
  ${user_information_portlet(user=c.user_info, full=False, title=_('Member information'))}
  ${user_groups_portlet(user=c.user_info, title=_("Member's groups"), full=False)}
</%def>



<%def name="title()">
  ${c.user_info.fullname}
</%def>

<h1>${_('What has %(user)s been up to?') % dict(user=c.user_info.fullname)}</h1>
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

%if h.check_crowds(['root']):
  <div>
    ${h.button_to(_('Log in as %(user)s') % dict(user=c.user_info.fullname), url=c.user_info.url(action='login_as'))}
  </div>
  <div style="clear: left; padding-top: 1em;">
    ${h.button_to(_('Award medals'), url=c.user_info.url(action='medals'))}
  </div>
%endif
