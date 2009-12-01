<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<div class="display_selection">
  <a href="${url(controller='profile', action='home')}" class="active">${_('grouped')}</a>
  <a href="${url(controller='profile', action='feed')}">${_('ungrouped')}</a>
</div>

%for m in c.user.memberships:
<div class="group_area">
  <%
     group = m.group
  %>
  <div class="group-logo">
    <img src="${group.url(action='logo', width=35, height=35)}" alt="logo" />
  </div>
  <div class="group-info">
    <span class="title">
      <a href="${group.url()}">${group.title}</a>
      (${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count = len(group.members))})
    </span>
    <br />
    <a href="${url(controller='groupforum', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
      ${group.group_id}@${c.mailing_list_host}
    </a>
  </div>
  <table class="group-news">
    <tr>
      <th>${_('Latest messages')}</th>
      <th class="right-column">${_('Latest events')}</th>
    </tr>
    <tr><td>
        <%
           messages = group.top_level_messages(True, 5)
        %>
        %if messages:
        <table class="group-messages">
          %for msg in messages:
          <tr>
            <td class="subject"><a href="${msg['thread'].url()}">${h.ellipsis(msg['thread'].subject, 30)}</a></td>
            <td class="date">${msg['last_reply'].date()}</td>
          </tr>
          %endfor
        </table>
        %else:
        ${_("No messages in group's forum")}
        %endif
      </td>
      <td class="right-column">
        <%
           events = group.filtered_events(['file_uploaded', 'page_created', 'page_modified', 'subject_modified'], 5)
        %>
        %if events:
        <table class="group-events">
          %for evt in events:
          <tr>
            <td class="subject">${evt.shortened()|n}</td>
            <td class="date">${evt.created.date()}</td>
          </tr>
          %endfor
        </table>
        %else:
        ${_("No events for the group.")}
        %endif
      </td>
    </tr>
    <tr class="more-links">
      <td><a href="${group.url(action='forum')}" class="more">${_('Group forum')}</a></td>
      <td class="right-column"><a href="${group.url(action='home')}" class="more">${_('Group events')}</a></td>
    </tr>
  </table>
  <br class="clear-left" />
</div>
%endfor
