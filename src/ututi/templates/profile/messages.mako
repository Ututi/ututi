<%inherit file="/profile/base.mako" />

<%def name="pagetitle()">
  ##${_('Messages')}
</%def>

##<div class="back-link">
##  <a class="back-link" href="${url(controller='profile', action='home')}">${_('Back to profile')}</a>
##</div>

<div class="portlet portletSmall portletGroupFiles mediumTopMargin">
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  <div class="single-title">
    <div class="floatleft bigbutton2">
      <h2 class="portletTitle bold category-title">
        ${_('Messages')}
      </h2>
    </div>
##  <div style="float: right; padding-top: 4px">
##    ${h.button_to(_('New topic'), url(controller=c.controller, action='new_thread', id=c.group_id, category_id=category.id))}
##  </div>
    <div class="clear"></div>
  </div>

  <div class="single-messages">

    % for message in c.messages:
      <% is_read = all(m.is_read for m in message.thread()) %>
      <div class="${'message-list-on1' if not is_read else 'message-list-off1'}">
        <div class="floatleft m-on">
          <div class="orange ${'bold' if not is_read else ''}">
            <a href="${url(controller='profile', action='message', id=message.id)}"
               class="post-title">${message.subject}</a>
            <span class="reply-count">
              (${ungettext("%(count)s message", "%(count)s messages", message.thread_length()) % dict(count=message.thread_length())})
            </span>
          </div>
          <div class="grey verysmall">${h.ellipsis(message.content, 50)}</div>
        </div>
        <div class="floatleft user">
          <div class="orange bold verysmall">
            <a href="${message.sender.url()}">${h.ellipsis(message.sender.fullname, 30)}</a>
          </div>
          <div class="grey verysmall">${h.fmt_dt(message.created_on)}</div>
        </div>
      </div>
    % endfor
  </div>

  <div style="padding: 10px 0 6px 10px;">
    % if c.user and c.messages:
      ${h.button_to(_('Mark all as read'), url(controller='profile', action='mark_messages_as_read'))}
    % elif not c.messages:
      ${_('No messages.')}
    % endif
  </div>

</div>
