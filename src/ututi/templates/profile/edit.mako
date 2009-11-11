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
    new AjaxUpload('#user-logo-button', {
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

<a class="back-link" href="${url(controller='profile', action='index')}">${_('back to the profile')}</a>

<h1>${_('Edit your profile')}</h1>

<form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" enctype="multipart/form-data">
  <table>
    <tr>
      <td style="width: 220px;">
        <div class="js-alternatives" id="user-logo">
          <img src="${url(controller='profile', action='logo', width='120', height='200')}" alt="User logo" id="user-logo-editable"/>
          <br />
          <a href="#" id="user-logo-button" class="btn"><span>${_('Change logo')}</span></a>
        </div>
        <br style="clear: left;"/>
        <div class="form-field no-break" style="text-align: center;">
          <input type="checkbox" name="logo_delete" id="logo_delete" value="delete" class="line"/>
          <label for="logo_delete">${_('Delete current logo')}</label>
        </div>
      </td>
      <td class="js-alternatives">
        ${h.input_line('fullname', _('Full name'))}
        ${h.input_line('site_url', _('Address of your website or blog'))}
        ${h.input_area('description', _('About yourself'), rows='6', cols='50')}

        <div class="form-field non-js">
          <label for="logo_upload">${_('Personal logo')}</label>
          <input type="file" name="logo_upload" id="logo_upload" class="line"/>
        </div>

        ${h.input_submit()}
      </td>
    </tr>
  </table>
</form>
<br/>
<h2>${_('Change your password')}</h2>
<table>
  <tr>
    <td style="width: 220px;">&nbsp;</td>
    <td>
      <form method="post" action="${url(controller='profile', action='password')}" id="change_password_form">
        ${h.input_line('password', _('Current password'))}
        ${h.input_line('new_password', _('New password'))}
        ${h.input_line('repeat_password', _('Repeat the new password'))}

        ${h.input_submit(_('Change password'))}
      </form>
    </td>
  </tr>
</table>
