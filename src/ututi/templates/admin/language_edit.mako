<%inherit file="/base.mako" />

<h1>${_('Language')}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_language')}"
      name="language_form" id="language_form" class="fullForm">
  ${h.input_hidden('id')}
  ${h.input_line('title', _('Language title'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
