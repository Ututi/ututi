<%inherit file="/messages/base.mako" />

<%def name="title()">
${_('New message')}
</%def>

##<div class="back-link">
##  <a class="back-link" href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category_id)}">${_('Back to the topic list')}</a>
##</div>

<form method="post" action="${url(controller='messages', action='new_message', user_id=c.recipient.id)}"
    id="new_message_form" class="fullForm" enctype="multipart/form-data">
  ${h.input_line('title', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>
