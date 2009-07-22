<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

<a href="${url(controller='groupforum', action='new_thread', id=c.group.id)}">${_("Post new topic")}</a>

<table id="forum-thread-list">
<tr>
  <th>${_('Subject')}</th><th>${_('Replies')}</th><th>${_('Last post')}</th>
</tr>
% for message in c.messages:
<tr>
  <td class="subject"><a href="${url(controller='groupforum', action='thread', id=c.group.id, thread_id=message['thread_id'])}">${message['subject']}</a></td>
  <td class="count">${message['reply_count']}</td>
  <td class="author">
    <a class="profile-link" href="${url(controller='user', id=message['last_reply_author_id'])}">${message['last_reply_author_title']}</a>
    <br/>
    <span class="date">${message['last_reply_date'].strftime("%Y.%m.%d %H:%M")}</span>
  </td>
</tr>
% endfor
</table>
