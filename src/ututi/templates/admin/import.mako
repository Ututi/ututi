<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('User import')}</h1>
<form name="user_import" method="post" action="/admin/import_users" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Structure import')}</h1>
<form name="structure_import" method="post" action="/admin/import_structure" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Groups import')}</h1>
<form name="groups_import" method="post" action="/admin/import_groups" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Group members import')}</h1>
<form name="group_members_import" method="post" action="/admin/import_group_members" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Subjects import')}</h1>
<form name="subjects_import" method="post" action="/admin/import_subjects" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('User logo import')}</h1>
<form name="user_logos_import" method="post" action="/admin/import_user_logos" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Group logo import')}</h1>
<form name="group_logos_import" method="post" action="/admin/import_group_logos" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Structure logo import')}</h1>
<form name="structure_logos_import" method="post" action="/admin/import_structure_logos" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Group file import')}</h1>
<form name="group_files_import" method="post" action="/admin/import_group_files" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>

<h1>${_('Subject file import')}</h1>
<form name="subject_files_import" method="post" action="/admin/import_subject_files" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>
