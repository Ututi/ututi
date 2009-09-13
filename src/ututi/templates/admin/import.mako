<%inherit file="/base.mako" />

<%def name="import_form(title, action)">
<h1>${title}</h1>
<form name="${action}" method="post" action="${url(controller='admin', action=action)}" enctype="multipart/form-data">
      <label for="file_upload">${_('CSV File')}</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>
</%def>

${self.import_form(_('User import'), 'import_users')}
${self.import_form(_('Structure import'), 'import_structure')}
${self.import_form(_('Groups import'), 'import_groups')}
