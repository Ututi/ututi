<%inherit file="/group/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/group/base.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/mailinglist.js')|n}
</%def>

<%def name="render_message(message, post_class='thread-post', show_actions=True)">
  <tr>
    <td colspan="2" class="author">
      <a href="${message.author_url}">${message.author_title}</a>
      <span class="created-on">${h.fmt_dt(message.sent)}</span>
      %if show_actions:
      <div style="float: right">
        ${h.button_to(_('Reply'), url(controller='mailinglist', action='thread', id=c.group.group_id, thread_id=c.thread.id) + '#reply')}
      </div>
      %endif
    </td>
  </tr>

<tr class="${post_class}">
  <td class="author-logo">
    <a href="${message.author_url}">
      %if message.author and message.author.logo is not None:
        <img alt="user-logo" src="${url(controller='user', action='logo', id=message.author.id, width='45', height='60')}"/>
      %else:
        ${h.image('/images/user_logo_45x60.png', alt='logo', id='group-logo')|n}
      %endif
    </a>
  </td>
  <td class="message">
    <div class="message-content">
      <div class="post-body">
        ${h.email_with_replies(message.body)}
      </div>
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
</%def>

<%def name="listThreads(action='thread', show_reply_count=True)">
  <div class="single-messages" id="single-messages">
    <%
       message_count = len(c.messages)
    %>

    % for index, message_obj in enumerate(c.messages):
      <%
          message = message_obj.info_dict()
          new_post = True
          post_url =  url(controller='mailinglist', action=action, id=c.group.group_id, thread_id=message['thread_id'])
          post_title = message['subject']
          post_text = message['body']
          post_date = h.fmt_dt(message['send'])
      %>
      <div class="${'message-list-on1' if new_post else 'message-list-off1'}${' last' if index == message_count - 1 else ''}">
        <div class="floatleft m-on">
          <div class="orange ${'bold' if new_post else ''}">
            <a href="${post_url}" class="post-title">${post_title}</a>
            %if show_reply_count:
              <span class="reply-count">
              (${ungettext("%(count)s reply", "%(count)s replies", message['reply_count']) % dict(count = message['reply_count'])})
              </span>
            %endif
          </div>
          <div class="grey verysmall">${h.ellipsis(post_text, 50)}</div>
        </div>
        <div class="floatleft user">
          <div class="orange bold verysmall">
            <a href="${message['author']['url']}">${message['author']['title']}</a>
          </div>
          <div class="grey verysmall">${post_date}</div>
        </div>
        <br style="clear: left;" />
      </div>
    % endfor
    <div id="pager">
      ${c.messages.pager(format='~3~', partial_param='js',
                         controller='mailinglist',
                         onclick='$("#pager").addClass("loading"); $("#single-messages").load("%s");'
                                 '$(document).scrollTop($("#single-messages").scrollTop());'
                                 ' return false;') }
    </div>
  </div>
</%def>

${next.body()}
