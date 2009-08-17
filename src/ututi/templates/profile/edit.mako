<%inherit file="/profile/base.mako" />

<%def name="title()">
  ${c.user.fullname}
</%def>

<h1>${_('Edit')}</h1>
<form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" enctype="multipart/form-data">
      <div class="form-field">
        <label for="fullname">${_('Full name')}</label>
        <input type="text" class="line" id="fullname" name="fullname" value="${c.user.fullname}"/>
      </div>
      <div class="form-field">
        <label for="logo_upload">${_('Personal logo')}</label>
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
