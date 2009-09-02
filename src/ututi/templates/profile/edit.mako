<%inherit file="/profile/base.mako" />

<%def name="title()">
  ${c.user.fullname}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/profile.css')|n}
  ${h.javascript_link('/javascripts/js-alternatives.js')|n}
  <script type="text/javascript">
  $(document).ready(function() {
    new AjaxUpload('#user-logo-editable', {
      action: '${url(controller="profile", action="logo_upload")}',
      name: 'logo',
      // Submit file after selection
      autoSubmit: true,
      responseType: false,
      onSubmit: function(file, extension) {
        if (! (extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))){
          alert('${_("The file type is not supported.")}');
          return false;
        }
      },
      onComplete: function(file, response) {
        var img_id = '#user-logo-editable';
        var img_src = "${url(controller='profile', action='logo', width='120', height='200')}";
        var timestamp = new Date().getTime();
        $(img_id).attr('src', img_src+'?'+timestamp);
      }
    });
   });
  </script>
</%def>

<h1>${_('Edit your profile')}</h1>

<form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" enctype="multipart/form-data">
  <table>
    <tr>
      <td style="width: 220px;">
        <div class="js-alternatives" id="user-logo">
          <span id="user-logo-msg" class="message js">${_('Click to change your logo')}</span>
          <img src="${url(controller='profile', action='logo', width='120', height='200')}" alt="User logo" id="user-logo-editable"/>
        </div>
        <br style="clear: left;"/>
        <div class="form-field no-break">
          <input type="checkbox" name="logo_delete" id="logo_delete" value="delete" class="line"/>
          <label for="logo_delete">${_('Delete current logo')}</label>
        </div>
      </td>
      <td class="js-alternatives">
        <div class="form-field">
          <label for="fullname">${_('Full name')}</label>
          <input type="text" id="fullname" name="fullname" value="${c.user.fullname}"/>
        </div>

        <div class="form-field">
          <label for="site_url">${_('Address of your website or blog')}</label>
          <input type="text" id="site_url" name="site_url" value="${c.user.site_url}"/>
        </div>

        <div class="form-field">
          <label for="description">${_('About yourself')}</label>
          <textarea rows="6" cols="50" name="description" id="description">${c.user.description}</textarea>
        </div>

        <div class="form-field non-js">
          <label for="logo_upload">${_('Personal logo')}</label>
          <input type="file" name="logo_upload" id="logo_upload" class="line"/>
        </div>

        <div>
          <span class="btn"><input type="submit" value="${_('Save')}"/></span>
        </div>
      </td>
    </tr>
  </table>
</form>
