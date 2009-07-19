<%inherit file="/group/home.mako" />

<h1>${_('Edit')}</h1>
<form method="post" action="${url(controller='group', action='update', id=c.group.id)}" name="edit_profile_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <input type="text" class="line" id="title" name="title" value="${c.group.title}"/>
  </div>
  <div class="form-field">
    <label for="description">${_('Description')}</label>
    <textarea class="line" name="description" id="description" cols="25" rows="5">${c.group.description}</textarea>
  </div>
  <div class="form-field">
    <label for="year">${_("Year")}</label>
    <select name="year" id="year">
      %for year in c.years:
      %if year == c.group.year:
      <option value="${year}" selected="selected">${year}</option>
      %else:
      <option value="${year}">${year}</option>
      %endif
      %endfor
    </select>
  </div>
  <div class="form-field">
    <label for="logo_upload">${_('Group logo')}</label>
    <input type="file" name="logo_upload" id="logo_upload" class="line"/>
  </div>
  <div class="form-field">
    <label for="logo_delete">${_('Delete current logo')}</label>
    <input type="checkbox" name="logo_delete" id="logo_delete" value="delete" class="line"/>
  </div>


  <div>
    <span class="btn"><input type="submit" value="${_('Save')}"/></span>
  </div>
</form>
