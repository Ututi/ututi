<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/mailinglist.js')|n}
</%def>

<a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>
<h1>${c.thread.subject}</h1>

<table id="forum-thread">
% for message in c.messages:
<tr class="thread-post">
  <td class="author-logo">
    <a href="${message.author.url()}">
      %if message.author.logo is not None:
        <img alt="user-logo" src="${url(controller='user', action='logo', id=message.author.id, width='45', height='60')}"/>
      %else:
        ${h.image('/images/user_logo_45x60.png', alt='logo', id='group-logo')|n}
      %endif
    </a>
  </td>
  <td class="message">
    <div class="message-header">
      <a href="${message.author.url()}">${message.author.fullname}</a>
      <span class="small">${h.fmt_dt(message.sent)}</span>
    </div>
    <div class="message-content">
      <div class="post-body">
        ${h.email_with_replies(message.body)}
      </div>
      <a class="btn" href="#reply"><span>${_('Reply')}</span></a>
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
  </td>
</tr>
% endfor
</table>

% if h.check_crowds(['member', 'admin']):
  <br />
  <a name="reply"/>
  <h2>${_('Reply')}</h2>
  <form method="post" action="${url(controller='mailinglist', action='reply', thread_id=c.thread.id, id=c.group.group_id)}"
       id="group_add_form" enctype="multipart/form-data">
    <div class="form-field">
      <label for="message">${_('Message')}</label>
      <textarea class="line" name="message" id="message" cols="80" rows="10" style="width: 620px;"></textarea>
    </div>
    ${h.input_submit(_('Reply'))}
  </form>
% endif
