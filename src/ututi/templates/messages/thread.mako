<%inherit file="/messages/base.mako" />

<div class="back-link">
  <a class="back-link" href="${url(controller='messages', action='index')}"
    >${_('Back to message list')}</a>
</div>

<div id="private-message-thread">
  <div class="single-title ">
    <h2>${c.message.subject}</h2>
    <div class=""></div>
  </div>

  <table id="forum-thread">
    <% first_seen = True %>
    % for message in c.thread:
    % if not message.is_read and first_seen:
    <% first_seen = False %>
    % endif
    <tr>
      <td colspan="2" class="author">
        <a href="${message.sender.url()}">${message.sender.fullname}</a>
        <span class="created-on">${h.fmt_dt(message.created_on)}</span>
      </td>
    </tr>
    <tr class="thread-post">
      <td class="author-logo">
        <a href="${message.sender.url()}">
          %if message.sender.logo is not None:
          <img alt="user-logo" src="${url(controller='user', action='logo', id=message.sender.id, width='45', height='60')}"/>
          %else:
          ${h.image('/images/user_logo_45x60.png', alt='logo', id='group-logo')|n}
          %endif
        </a>
      </td>
      <td class="forum_post">
        <div class="forum_post-content">
          <div class="post-body">
            ${h.nl2br(message.content)}
          </div>
        </div>
      </td>
    </tr>
    % endfor
  </table>

  <div class="reply click2show">
    <div class="action-tease click hide">${_('Write a reply')}</div>
    <div class="action-block show" id="send-message-block">
      <form method="POST" action="${url(controller='messages', action='reply', id=c.message.id)}" id="message_form" enctype="multipart/form-data">
        <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />
        <textarea name="message"></textarea>
        ${h.input_submit(_('Reply'), id="message_send", class_='dark inline action-button')}
        <a class="cancel-button click" href="#cancel">${_("Cancel")}</a>
      </form>
    </div>
  </div>
</div>
