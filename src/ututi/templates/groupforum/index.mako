<%inherit file="/group/home.mako" />
<%namespace file="/portlets/group.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_changes_portlet()}
</div>
</%def>


<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<div id="page_header">
  <a class="btn" href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}"><span>${_("New topic")}</span></a>
</div>
<br class="clear-left"/>




%if not c.messages:
  <span class="small">${_('No messages yet.')}</span>
%else:
<table id="forum-thread-list">
<tr>
  <th>${_('email subject')}</th>
  <th>${_('replies')}</th>
  <th>${_('latest email')}</th>
  <th>${_('last author')}</th>
</tr>

% for message in c.messages:
<tr>
  <td class="subject">
    <a class="thread-subject" href="${url(controller='groupforum', action='thread', id=c.group.group_id, thread_id=message['thread_id'])}">
      ${message['subject']}
    </a>
  </td>
  <td class="count">
    ${ungettext("%(count)s reply", "%(count)s replies", message['reply_count']) % dict(count = message['reply_count'])}
  </td>
  <td class="date">
    ${h.fmt_dt(message['send'])}
  </td>
  <td class="author">
    <a href="${message['author'].url()}">${message['author'].fullname}</a>
  </td>
</tr>
% endfor
</table>
%endif
