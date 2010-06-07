<%inherit file="/mailinglist/base.mako" />

<div style="float: right">
  % if h.check_crowds(['member', 'admin']):
    ${h.button_to(_("New topic"), url(controller='mailinglist', action='new_thread', id=c.group.group_id))}
  % endif
</div>

<br class="clear-left"/>

%if not c.messages:
  <span class="small">${_('No messages yet.')}</span>
%else:

    <div class="single-messages" id="single-messages">

      % for message in c.messages:
        <%
            new_post = True
            post_url =  url(controller='mailinglist', action='thread', id=c.group.group_id, thread_id=message['thread_id'])
            post_title = message['subject']
            post_text = message['body']
            post_date = h.fmt_dt(message['send'])
        %>
        <div class="${'message-list-on1' if new_post else 'message-list-off1'}">
          <div class="floatleft m-on">
            <div class="orange ${'bold' if new_post else ''}">
              <a href="${post_url}" class="post-title">${post_title}</a>
              <span class="reply-count">
                ${ungettext("%(count)s reply", "%(count)s replies", message['reply_count']) % dict(count = message['reply_count'])}
              </span>
            </div>
            <div class="grey verysmall">${h.ellipsis(post_text, 50)}</div>
          </div>
          <div class="floatleft user">
            <div class="orange bold verysmall">
              <a href="${message['author'].url()}">${message['author'].fullname}</a>
            </div>
            <div class="grey verysmall">${post_date}</div>
          </div>
        </div>
      % endfor

    </div>

% endif
