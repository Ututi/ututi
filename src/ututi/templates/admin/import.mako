<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="import_form(action)">
<form name="${action}" method="post" action="${h.url_for(action=action)}" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>
</%def>

<h1>${_('User import')}</h1>
${self.import_form('import_users')}

<h1>${_('Structure import')}</h1>
${self.import_form('import_structure')}

<h1>${_('Groups import')}</h1>
${self.import_form('import_groups')}

<h1>${_('Group members import')}</h1>
${self.import_form('import_group_members')}

<h1>${_('Subjects import')}</h1>
${self.import_form('import_subjects')}

<h1>${_('User logo import')}</h1>
${self.import_form('import_user_logos')}

<h1>${_('Group logo import')}</h1>
${self.import_form('import_group_logos')}

<h1>${_('Structure logo import')}</h1>
${self.import_form('import_structure_logos')}

<h1>${_('Group file import')}</h1>
${self.import_form('import_group_files')}

<h1>${_('Subject file import')}</h1>
${self.import_form('import_subject_files')}

<h1>${_('Group page import')}</h1>
${self.import_form('import_group_pages')}

<h1>${_('Subject page import')}</h1>
${self.import_form('import_subject_pages')}
