<%inherit file="/mailinglist/base.mako" />


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
              <a href="${message['author'].url()}">${message['author'].fullname}</a>
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

  <%self:rounded_block class_="portletGroupFiles portletGroupMailingList">
    <div class="single-title">
      <div class="floatleft bigbutton2">
        <h2 class="portletTitle bold category-title">${_('Group mail')}</h2>
      </div>
      % if h.check_crowds(['member', 'admin']):
      <div style="float: right">
        ${h.button_to(_("New topic"), url(controller='mailinglist', action='new_thread', id=c.group.group_id), method='get')}
      </div>
      % endif
      <div class="clear"></div>
    </div>

    %if not c.messages:
      <div class="single-messages" id="single-messages">
        <div class="no-messages">${_('No messages yet.')}</div>
      </div>
    %else:
      ${listThreads()}
    %endif
 </%self:rounded_block>
