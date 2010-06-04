<%inherit file="/forum/base.mako" />

<%def name="title()">
${_('New topic')}
</%def>

<a class="back-link" href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category_id)}">${_('Back to the topic list')}</a>

<h1>${_('New topic')}</h1>

<form method="post" action="${url(controller=c.controller, action='post', id=c.group_id, category_id=c.category_id)}"
     id="group_add_form" class="fullForm" enctype="multipart/form-data">
  ${h.input_line('title', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>
