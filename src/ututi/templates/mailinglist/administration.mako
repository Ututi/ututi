<%inherit file="/mailinglist/base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/moderation.js')}
</%def>

<%def name="approvedMessage()">
  <div class="approved-message">
    ${_('Message approved')}
  </div>
</%def>

<%def name="rejectedMessage()">
  <div class="rejected-message">
    ${_('Message rejected')}
  </div>
</%def>

<%def name="warningMessage()">
  <div class="warning-message">
    ${_('Message already approved')}
  </div>
</%def>

<%def name="listThreadsActions(message)">
  <div class="moderation-actions">
    <div class="loading-message">
      ${_('Working...')}
    </div>
  <div class="error-message">
    ${_('Error: could not reach server or this message was already moderated. Please try refreshing the page.')}
  </div>
    <div class="moderation-action-buttons">
      ${h.button_to(_('Approve'), url=message.url(action='approve_post_from_list'), class_='btn btn-approve')}
      ${h.button_to(_('Reject'), url=message.url(action='reject_post_from_list'), class_='btn btn-reject')}
    </div>
  </div>
</%def>

<div class="back-link">
  <a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>
</div>

<%b:light_table title="${_('Emails that are allowed to post to the mailing list of this group')}"
                items="${c.group.whitelist}"
                class_="group-whitelist">
  <%def name="row(item)">
     <td class="email">
       <a href="mailto:${item.email}">${item.email}</a>
     </td>
     <td class="actions">
       %if item.not_invited_to_group:
       <form style="display: inline;" method="post" action="${c.group.url(action='invite_members')}">
         <input type="hidden" name="emails" value="${item.email}" />
         <input type="submit" class="text_button" value="${_('Invite to group')}" />
       </form>
       %endif
       <form style="display: inline;" method="post" action="${c.group.url(action='remove_from_whitelist')}">
         <input type="hidden" name="email" value="${item.email}" />
         <input type="submit" class="text_button" style="color: #888;" value="${_('Remove')}" />
       </form>
     </td>
  </%def>
  <%def name="footer(items)">
     <td colspan="2">
       <form method="post" action="${c.group.url(controller='mailinglist', action='add_to_whitelist')}">
         <div style="padding-top: 5px" >
           <label class="textField" for="email" style="float: left">
             <span class="labelText">Email:</span>
             <input type="text" name="email" id="email" style="width: 200px" />
             <span class="edge"></span>
           </label>
           <div style="float: left; padding-left: 5px;">
             ${h.input_submit('Add')}
           </div>
         </div>
       </form>
     </td>
  </%def>
  <%def name="empty_rows()">
    <tr class="last">
     ${footer([])}
    </tr>
  </%def>
</%b:light_table>

<%self:rounded_block class_="moderation-queue portletGroupFiles portletGroupMailingList">
  <div class="single-title">
    <div class="floatleft bigbutton2">
      <h2 class="portletTitle bold category-title">${_('Moderation queue')}</h2>
    </div>
    <div class="clear"></div>
  </div>
  <div class="single-messages with-moderation-actions" id="single-messages">
  %if not c.messages:
      <div class="no-messages">${_('No messages to be moderated yet.')}</div>
  %else:
      ${self.listThreads(action='moderate_post', show_reply_count=False, pager=False)}
  %endif
  </div>
</%self:rounded_block>
