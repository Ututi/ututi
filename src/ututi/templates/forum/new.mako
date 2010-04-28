<%inherit file="/forum/index.mako" />

<%def name="title()">
${_('New topic')}
</%def>

<a class="back-link" href="${h.url_for(action='index')}">${_('Back to the topic list')}</a>

<h1>${_('New topic')}</h1>

<form method="post" action="${url.current(action='post')}"
     id="group_add_form" enctype="multipart/form-data">
  ${h.input_line('title', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  ${h.input_submit(_('Post'))}
</form>
