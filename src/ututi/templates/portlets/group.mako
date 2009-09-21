<%inherit file="/portlets/base.mako"/>

<%def name="group_info_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_info_portlet">
    <%def name="header()">
      ${_('Group information')}
    </%def>
    %if group.logo is not None:
      <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${group.title}</h4>
      <span class="small">${group.location and ' | '.join(group.location.path)}</span><span class="small year"> | ${group.year.year}</span><br />
      <a class="small" href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a><br />
      <span class="small">${len(group.members)} ${_('members')}</span>
    </div>
    <div class="description small">
      ${group.description}
    </div>
    <br style="clear: both;" />
    %if group.is_admin(c.user):
      <span class="portlet-link">
        <a class="small" href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      </span>
    %endif
    %if group.is_member(c.user):
      <div class="click2show">
        <span class="click">${_("My group settings")}</span>
        <div class="show">
          %if group.is_subscribed(c.user):
            <a href="${group.url(action='unsubscribe')}" class="btn inactive"><span>${_("Do not get email")}</span></a>
          %else:
            <a href="${group.url(action='subscribe')}" class="btn"><span>${_("Get email")}</span></a>
          %endif
          <a href="${group.url(action='leave')}" class="btn inactive"><span>${_("Leave group")}</span></a>
        </div>
      </div>
      <br style="clear: both;" />
    %endif
  </%self:portlet>
</%def>

<%def name="group_changes_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_changes_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Latest changes')}
    </%def>
    <ul class="event-list">
      %for event in group.group_events[:5]:
        <li>${event.render()|n}</li>
      %endfor
    </ul>
    <a class="more" href="${url(controller='group', action='home', id=group.group_id)}" title="${_('More')}">${_('More')}</a>
  </%self:portlet>
</%def>

<%def name="group_members_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_members_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Recently seen')}
    </%def>
    %for member in group.last_seen_members[:3]:
    <div class="user-logo-link">
      <div class="user-logo">
        <a href="${url(controller='user', action='index', id=member.id)}" title="${member.fullname}">
          %if member.logo is not None:
            <img src="${url(controller='user', action='logo', id=member.id, width=40, height=40)}" alt="${member.fullname}"/>
          %else:
            ${h.image('/images/user_logo_small.png', alt=member.fullname)|n}
          %endif
        </a>
      </div>
      <div>
        <a href="${url(controller='user', action='index', id=member.id)}" title="${member.fullname}">
          <span class="small">${member.fullname}</span>
        </a>
      </div>
    </div>
    %endfor
    <br style="clear: both;" />
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='members', id=group.group_id)}" title="${_('More')}">${_('More') | h.ellipsis}</a>
    </span>
    <br style="clear: both;" />
  </%self:portlet>
</%def>

<%def name="group_watched_subjects_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="watched_subjects_portlet" portlet_class="inactive XXX">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %for subject in group.watched_subjects:
    <div>
      <a href="${subject.url()}">
          ${subject.title}
      </a>
    </div>
    %endfor
    <br style="clear: both;" />
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='subjects', id=group.group_id)}" title="${_('More')}">${_('More')}</a>
    </span>
    <br style="clear: both;" />
  </%self:portlet>
</%def>

<%def name="group_forum_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="forum_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Group messages')}
    </%def>
    %if group.all_messages:
      <table id="group_latest_messages">
        %for message in group.all_messages[:5]:
        <tr>
          <td class="time">${h.fmt_shortdate(message.sent)}</td>
          <td class="subject"><a href="${message.url()}" title="${message.subject}, ${message.author.fullname}">${h.ellipsis(message.subject, 25)}</a></td>
        </tr>
        %endfor
      </table>
    %else:
      <div class="notice">${_("The groups's forum is empty.")}</div>
    %endif
    <br style="clear: both;" />
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='forum', id=group.group_id)}" title="${_('More')}">${_('More')}</a>
    </span>

    <a href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}" class="btn"><span>${_("New topic")}</span></a>
    <br style="clear: both;" />
  </%self:portlet>
</%def>
