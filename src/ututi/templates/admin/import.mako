<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Data import')}</h1>
<form name="user_import" method="post" action="/admin/import_users" enctype="multipart/form-data">
      <label for="file_upload">CSV File</label>
      <input type="file" name="file_upload" id="file_upload"/>
      <input type="submit" value="Upload" name="Upload"/>
</form>
