<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Files')}</h1>

%if c.files:
    <ul id="file_list">
    %for file in c.files:
         <li>
                <a href="${url(controller='files', action='get', id=file.id)}" class="file-link">${file.title}</a>
         </li>
    %endfor
    </ul>
%endif

<h2>${_('Create new')}</h2>
<form method="post" action="${url(controller='files', action='upload')}"
      name="file_upload_form" id="file_upload_form" enctype="multipart/form-data">
      <div>
        <label for="title">${_('Title')}</label>
        <input type="text" id="title" name="title"/>
      </div>
      <div>
        <label for="description">${_('Description')}</label>
        <textarea name="description" id="description" cols="25" rows="5"></textarea>
      </div>
      <div>
        <label for="upload">${_("Upload")}</label>
        <input type="file" name="upload" id="upload"/>
      </div>
      <div>
        <input type="submit" value="${_('Save')}"/>
      </div>
</form>
