<%inherit file="/mailinglist/base.mako" />

<%def name="listThreadsActions(message)">
  <div class="floatleft moderation-actions">
    ${h.button_to(_('Accept'), url=message.url(action='accept_post_from_list'))}
    ${h.button_to(_('Reject'), url=message.url(action='reject_post_from_list'))}
  </div>
</%def>

<div class="back-link">
  <a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>
</div>

<%self:rounded_block class_="portletGroupFiles portletGroupMailingList">
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
      ${self.listThreads(action='moderate_post', show_reply_count=False)}
  %endif
  </div>
</%self:rounded_block>
