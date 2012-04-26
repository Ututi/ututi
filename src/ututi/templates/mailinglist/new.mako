<%inherit file="/mailinglist/base.mako" />

<%def name="title()">
${_('New topic')}
</%def>

<div class="back-link">
  <a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>
</div>

<form method="post" action="${url(controller='mailinglist', action='post', id=c.group.group_id)}"
      id="new_message_form" class="fullForm" enctype="multipart/form-data">
  ${h.input_line('subject', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>
