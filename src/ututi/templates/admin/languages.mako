<%inherit file="/base.mako" />

%if c.languages:
  <table id="languages_list" style="width: 100%;">
    <tr>
      <th>${_('Id')}</th>
      <th>${_('Language')}</th>
      <th>${_('Actions')}</th>
    </tr>

    %for language in c.languages:
    <tr>
      <td>${language.id}</td>
      <td>${language.title}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_language", id=language.id)) }</td>
    </tr>
    %endfor
  </table>
%endif


<h1>${_('Languages')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='add_language')}"
      name="language_form" id="language_form" class="fullForm">
  ${h.input_line('id', _('Language id'))}
  ${h.input_line('title', _('Language title'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
