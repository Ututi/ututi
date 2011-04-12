<%inherit file="/messages/base.mako" />


<%def name="pagetitle()">
  ${_('Messages')}
</%def>

<div class="tip">
  ${_('You can send a new message to a user from his or her public profile page.')}
</div>

##<div class="back-link">
##  <a class="back-link" href="${url(controller='profile', action='home')}">${_('Back to profile')}</a>
##</div>

##  <div style="float: right; padding-top: 4px">
##    ${h.button_to(_('New topic'), url(controller=c.controller, action='new_thread', id=c.group_id, category_id=category.id))}
##  </div>


<div id="private-messages">
  <div class="single-title">
        ${_('Message')}
  </div>

  <div class="single-messages">

    % for message in c.messages:
      <% is_read = all((m.sender == c.user or m.is_read) for m in message.thread()) %>
      <div class="${'message-list-on1' if not is_read else 'message-list-off1'}">
        <div class="floatleft m-on">
          <div class="orange ${'bold' if not is_read else ''}">
            <a href="${url(controller='messages', action='thread', id=message.id)}"
               class="post-title">${message.subject}</a>
            <span class="reply-count">
              (${ungettext("%(count)s message", "%(count)s messages", message.thread_length()) % dict(count=message.thread_length())})
            </span>
            ${h.button_to('Delete', url(controller='messages', action='delete', id=message.id), style='display: none')}
            <a href="#" class="delete-message-link"><img src="/img/icons/cross_small.png" alt="delete" /></a>
          </div>
          <div class="grey verysmall">${h.ellipsis(message.content, 50)}</div>
        </div>
        <div class="floatleft user">
          <div class="orange bold verysmall">
            %if message.sender == c.user:
              <a href="${message.recipient.url()}">${h.ellipsis(message.recipient.fullname, 30)}</a>
            %else:
              <a href="${message.sender.url()}">${h.ellipsis(message.sender.fullname, 30)}</a>
            %endif
          </div>
          <div class="grey verysmall">${h.fmt_dt(message.created_on)}</div>
        </div>
        <br style="clear: left;" />
      </div>
    % endfor
  </div>

  <div style="padding: 10px 0 6px 10px;">
    % if c.user and c.messages:
      ${h.button_to(_('Mark all as read'), url(controller='messages', action='mark_all_as_read'))}
    % elif not c.messages:
      ${_('No messages.')}
    % endif
  </div>

</div>

<script>
    $('.delete-message-link').click(function() {
        $(this).siblings('form').submit();
    });
</script>
