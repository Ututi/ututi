<%inherit file="/base.mako" />

<h1>${_('I18n texts')}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_i18n_text')}"
      name="text_form" id="text_form" class="fullForm">
  ${h.input_hidden('id')}
  ${h.input_hidden('language')}
  ${h.input_area('text', _('Text'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
