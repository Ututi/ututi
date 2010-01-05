<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Files')}</h1>

<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s file", "found %(count)s files", c.files.item_count) % dict(count = c.files.item_count)})</span>
  </h3>
  <ul id="file_list">
    %for file in c.files:
     <li>
       <a href="${url(controller='files', action='get', id=file.id)}" class="file-link">${file.title}</a>
       %if file.parent is not None:
       (<a href="${file.parent.url()}" class="parent-link">${getattr(file.parent, 'title', 'email')}</a>)
       %endif
       (<a href="${file.created.url()}" class="author-link">${file.created.fullname}</a>)
     </li>
    %endfor
  </ul>
  <div id="pager">${c.files.pager(format='~3~') }</div>
</div>

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
