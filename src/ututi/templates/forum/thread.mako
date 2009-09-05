<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

% for message in c.messages:
<div class="thread-post">
  <div class="post-title">${message.author.fullname} -- ${message.subject}</div>
  <pre class="post-body">
    ${message.body}
  </pre>
  % if message.attachments:
  <ul class="post-attachments">
    % for file in message.attachments:
      <li>
         <a href="${file.url()}" class="file-link">${file.title}</a>
      </li>
    % endfor
  </ul>
  % endif
</div>
% endfor
<form method="post" action="${url(controller='groupforum', action='reply', thread_id=c.thread.id, id=c.group.group_id)}"
     id="group_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="message">${_('Message')}</label>
    <textarea class="line" name="message" id="message" cols="80" rows="25"></textarea>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Reply')}"/>
    </span>
  </div>
</form>
</table>
