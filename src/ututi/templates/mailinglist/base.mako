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
      <a href="${message.author.url()}">${message.author.fullname}</a>
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
    <a href="${message.author.url()}">
      %if message.author.logo is not None:
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

${next.body()}
