<%inherit file="/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

<table id="forum-thread-list">
<tr>
  <th>${_('Subject')}</th><th>${_('Replies')}</th><th>${_('Last post')}</th>
</tr>
% for message in c.messages:
<tr>
  <td>${message['subject']}</td>
  <td>${message['reply_count']}</td>
  <td>
    <a class="profile-link XXX" href="${h.url_for(controller='user', id=message['last_reply_author_id'])}">${message['last_reply_author_title']}</a>
    <span class="date">${message['last_reply_date']}</span>
  </td>
</tr>
% endfor
</table>
