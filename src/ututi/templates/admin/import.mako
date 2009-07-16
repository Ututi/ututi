<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="import_form(title, action)">
<h1>${title}</h1>
<form name="${action}" method="post" action="${h.url_for(action=action)}" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>
</%def>

${self.import_form(_('User import'), 'import_users')}
${self.import_form(_('Structure import'), 'import_structure')}
${self.import_form(_('Groups import'), 'import_groups')}
${self.import_form(_('Group members import'), 'import_group_members')}
${self.import_form(_('Subjects import'), 'import_subjects')}
${self.import_form(_('User logo import'), 'import_user_logos')}
${self.import_form(_('Group logo import'), 'import_group_logos')}
${self.import_form(_('Structure logo import'), 'import_structure_logos')}
${self.import_form(_('Group file import'), 'import_group_files')}
${self.import_form(_('Subject file import'), 'import_subject_files')}
${self.import_form(_('Group page import'), 'import_group_pages')}
${self.import_form(_('Subject page import'), 'import_subject_pages')}
${self.import_form(_('Group watched subject import'), 'import_group_watched_subjects')}
${self.import_form(_('User watched subject import'), 'import_user_ignored_subjects')}
${self.import_form(_('User ignored subject import'), 'import_user_watched_subjects')}
