<%inherit file="/group/home.mako" />

<h1>${_('Edit group front page')}</h1>

<form method="post" action="${url(controller='group', action='update_page', id=c.group.group_id)}"
     id="group_page_edit_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="page_content">${_('Content')}</label>
    <textarea class="ckeditor" name="page_content" id="page_content" cols="80" rows="15">${c.group.page}</textarea>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
