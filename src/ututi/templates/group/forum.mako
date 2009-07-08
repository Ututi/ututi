<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

<table id="forum-thread-list">
<tr>
  <th>${_('Subject')}</th><th>${_('Replies')}</th><th>${_('Last post')}</th>
</tr>
% for message in c.messages:
<tr>
  <td class="subject">${message['subject']}</td>
  <td class="count">${message['reply_count']}</td>
  <td class="author">
    <a class="profile-link" href="${h.url_for(controller='profile', id=message['last_reply_author_id'])}">${message['last_reply_author_title']}</a>
    <br/>
    <span class="date">${message['last_reply_date'].strftime("%Y.%m.%d %H:%M")}</span>
  </td>
</tr>
% endfor
</table>
