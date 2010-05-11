<%inherit file="/group/home.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>


<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<div id="page_header">
  % if h.check_crowds(['member', 'admin']):
    <a class="btn" href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}"><span>${_("New topic")}</span></a>
  % endif
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
    <a class="thread-subject" href="${url(controller='mailinglist', action='thread', id=c.group.group_id, thread_id=message['thread_id'])}">
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
