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
       (<a href="${file.parent.url()}"
           class="parent-link"
           style="${file.parent.deleted_on is not None and 'text-decoration: line-through;' or ''}">${getattr(file.parent, 'title', 'email')}</a>)

       %endif
       (<a href="${file.created.url()}" class="author-link">${file.created.fullname}</a>)
       <br/>
       ${_('deleted by <a href="%(user_url)s">%(user)s</a> on %(date)s') % dict(date = h.fmt_dt(file.deleted_on),\
                                                                                user=file.deleted.fullname,\
                                                                                user_url=file.deleted.url()) |n}
       <br/>
       <div class="click2show">
         <a href="#" class="click">${_('undelete')}</a>
         <form class="undelete_form show" method="POST" action="${url(controller='files', action='undelete', id=file.id)}">
           <div>
             <label for="parent_id">${_('Parent id')}</label>
             <input type="text" name="parent_id" size="10"/>
             <input type="submit" value="${_('Undelete')}"/>
             <div class="message">${_('Parent id can be a path, e.g. subject/vu/matematika, group/matematikai, or a numeric id.')}</div>
           </div>
         </form>
       </div>
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
