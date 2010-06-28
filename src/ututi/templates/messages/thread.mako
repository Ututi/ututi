<%inherit file="/messages/base.mako" />

<div class="back-link">
  <a class="back-link" href="${url(controller='messages', action='index')}"
    >${_('Back to message list')}</a>
</div>

  <%self:rounded_block class_="portletGroupFiles portletGroupMailingList smallTopMargin">

<div class="single-title">
  <h2 class="portletTitle bold category-title" style="padding-bottom: 7px">${c.message.subject}</h2>
</div>

<table id="forum-thread">
<% first_seen = True %>
% for message in c.thread:
  % if not message.is_read and first_seen:
    <% first_seen = False %>
    <tr>
      <td colspan="2"><a name="unseen"></a><hr /><td>
    </tr>
  % endif
  <tr>
    <td colspan="2" class="author">
      %if message.sender == c.user:
        &rarr; <a href="${message.recipient.url()}">${message.recipient.fullname}</a>
      %else:
        <a href="${message.sender.url()}">${message.sender.fullname}</a>
      %endif
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

<div id="reply-section">
  <a name="reply"></a>
  <h2>${_('Reply')}</h2>
  <br />
  <form method="post" action="${url(controller='messages', action='reply', id=c.message.id)}"
        id="message_reply_form" class="fullForm" enctype="multipart/form-data">
    ${h.input_area('message', _('Message'))}
    <br />
    ${h.input_submit(_('Reply'))}
  </form>
</div>

</%self:rounded_block>
