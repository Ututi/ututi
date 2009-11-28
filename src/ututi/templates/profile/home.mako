<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

%for m in c.user.memberships:
<div class="group_area">
  <%
     group = m.group
  %>
  <div class="group-logo">
    <img src="${group.url(action='logo', width=35, height=35)}" alt="logo" />
  </div>
  <div class="group-info">
    <span class="title"><a href="${group.url()}">${group.title}</a></span>
    <span class="school-link"><a href="${group.location.url()}">${' | '.join(group.location.path)}</a></span><br />
    <a href="${url(controller='groupforum', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
      ${group.group_id}@${c.mailing_list_host}
    </a>
  </div>
  <table class="group-news">
    <tr><td>
        %if group.all_messages:
        <table class="group-messages">
          %for msg in group.all_messages[:5]:
          <tr>
            <td class="subject"><a href="${msg.url()}">${h.ellipsis(msg.subject, 30)}</a></td>
            <td class="date">${msg.sent.date()}</td>
          </tr>
          %endfor
        </table>
        %else:
        ${_("No messages in group's forum")}
        %endif
      </td>
      <td>
        %if group.group_events:
        <table class="group-events">
          %for evt in group.group_events[:3]:
          <tr>
            <td class="subject">${evt.render()|n}</td>
            <td class="date">${evt.when()}</td>
          </tr>
          %endfor
        </table>
        %else:
        ${_("No events for the group.")}
        %endif
      </td>
    </tr>
  </table>
  <br class="clear-left" />
</div>
%endfor

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
