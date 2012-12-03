<%inherit file="/mailinglist/base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" />

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

<div class="back-link">
  <a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>
</div>

<%def name="group_whitelist(group)">
<div class="group-whitelist moderation-list">
  <div class="title">
    ${_('Emails that are allowed to post to the mailing list of this group')}:
  </div>
  <div class="add-whitelist-email">
    <form id="whitelist_email_form" method="post" action="${group.url(controller='mailinglist', action='add_to_whitelist')}">
      <input type="hidden"
             id="reload_url" name="reload_url" value="${group.url(controller='mailinglist', action='whitelist_js')}" />
      <div style="padding-top: 5px" >
        <label class="textField" for="email" style="float: left">
          <span class="labelText">${_("Add email")}:</span>
          <input type="text" name="email" id="email" style="width: 200px" />
          <span class="edge"></span>
        </label>
        <div style="float: left; padding-left: 5px;">
          ${h.input_submit(_('Add'))}
        </div>
        <div id="whitelist_email_error" style="float: left; padding-left: 5px;">
          <form:error name="email"/>
        </div>
      </div>
    </form>
    <div style="clear: both;"></div>
  </div>
  <table class="email-whitelist">
    <tbody>
    %for item in group.whitelist:
      <tr>
        <td class="email">
          <a href="mailto:${item.email}">${item.email}</a>
        </td>
        <td style="text-align: right;">
          <form style="display: inline;" method="post" action="${group.url(controller='mailinglist', action='remove_from_whitelist')}">
            <input type="hidden" name="email" value="${item.email}" />
            <input type="submit" name="remove" value="${_('Remove')}" class="text_button"/>
          </form>
        </td>
      </tr>
    %endfor
    </tbody>
  </table>
</div>
</%def>

<%self:group_whitelist group="${c.group}" />

<div class="moderation-queue moderation-list">
  <div class="title">
    ${_('Moderation queue')}:
  </div>
  %if c.messages:
  <table class="moderation-table">
    <thead>
      <tr>
        <th class="message">${_('Message')}</td>
        <th class="author-and-date">${_('Author and date')}</td>
        <th class="actions">${_('Actions')}</td>
      </tr>
    </thead>
    <tbody>
      %for message in c.messages:
      <tr>
        <td class="message">
          <a href="${url(controller='mailinglist', action='moderate_post', id=c.group.group_id, thread_id=message.id)}">${h.ellipsis(message.subject, 36)}</a><br/><span class="excerpt">${h.ellipsis(message.body, 42)}</span>

        </td>
        <td class="author-and-date">
          <a class="author" href="${message.author_or_anonymous.url()}">
            ${h.ellipsis(message.author_or_anonymous.fullname, 24)}
          </a><br/>
          <span class="date">${h.fmt_normaldate(message.sent)}</span>
        </td>
        <td class="actions">
          <span class="moderation-actions">
            ${h.button_to(_("Approve"), url=url(controller='mailinglist', action='approve_post_from_list', id=c.group.id, thread_id=message.id),
                          type='image', src=url('/img/icons/tick_10.png'), name="approve")}
            ${h.button_to(_("Reject"), url=url(controller='mailinglist', action='reject_post_from_list', id=c.group.id, thread_id=message.id),
                          type='image', src=url('/img/icons/cross_small.png'), name="reject")}
          </span>
        </td>
      </tr>
      %endfor
    </tbody>
  </table>
  %else:
    <p id="empty-queue-notice">${_('No messages to be moderated yet.')}</p>
  %endif
</div>
