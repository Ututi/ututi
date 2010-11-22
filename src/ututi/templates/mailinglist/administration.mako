<%inherit file="/mailinglist/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  <script type="text/javascript">
  $(document).ready(function(){
      $('.btn-accept, .btn-reject').click(function() {
          var panel = $(this).closest('.moderation-actions');
          panel.addClass('loading');
          $.ajax({
            url: $(this).closest('form').attr('action') + '?js=1',
            success: function(data) {
              panel.removeClass('loading');
              panel.removeClass('error');
              panel.html(data);
              panel.closest('.message-list-on1, .message-list-off1')
                .find('a').addClass('disabled').removeAttr('href');
            },
            error: function(data) {
              panel.removeClass('loading');
              panel.addClass('error');
            }
          });
          return false;
      });
  });
  </script>
</%def>

<%def name="listThreadsActions(message)">
  <div class="floatright moderation-actions">
    <div class="loading-message">
      ${_('Working...')}
    </div>
    <div class="error-message">
      ${h.literal(_('Error: could not reach server.'))}
    </div>
    <div class="moderation-action-buttons">
      ${h.button_to(_('Accept'), url=message.url(action='accept_post_from_list'), class_='btn btn-accept')}
      ${h.button_to(_('Reject'), url=message.url(action='reject_post_from_list'), class_='btn btn-reject')}
    </div>
  </div>
</%def>

<%def name="acceptedMessage()">
  <div class="accepted-message">
    ${_('Message accepted')}
  </div>
</%def>

<%def name="rejectedMessage()">
  <div class="rejected-message">
    ${_('Message rejected')}
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
      ${self.listThreads(action='moderate_post', show_reply_count=False, pager=False)}
  %endif
  </div>
</%self:rounded_block>
