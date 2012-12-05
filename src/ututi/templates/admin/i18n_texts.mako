<%inherit file="/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

%if c.texts:
  <table id="texts_list" style="width: 100%;">
    <tr>
      <th>${_('Id')}</th>
      <th>${_('Language')}</th>
      <th>${_('Actions')}</th>
    </tr>

    %for text in c.texts:
    <tr>
      <td>${text.id}</td>
      <td>${text.language.title}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_i18n_text", id=text.id, lang=text.language.id)) }</td>
    </tr>
    %endfor
  </table>
%endif


<h1>${_('I18n texts')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='add_i18n_text')}"
      name="text_form" id="text_form" class="fullForm">
  ${h.input_line('id', _('Text id'))}
  ${h.input_line('language', _('Text language'))}
  ${h.input_wysiwyg('i18n_text', _('Text'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>
