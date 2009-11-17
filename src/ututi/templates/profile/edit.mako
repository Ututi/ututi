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

<h1>${_('Edit your profile')}</h1>

<a class="back-link" href="${url(controller='profile', action='index')}">${_('back to the profile')}</a>

<form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" id="edit_profile_form" enctype="multipart/form-data">
  <table>
    <tr>
      <td style="width: 220px;">
        <div class="js-alternatives" id="user-logo">
          <img src="${url(controller='profile', action='logo', width='120', height='200')}" alt="User logo" id="user-logo-editable"/>
          <br />
          <a href="#" id="user-logo-button" class="btn"><span>${_('Change logo')}</span></a>
        </div>
        <br style="clear: left;"/>
        <div class="form-field no-break">
          <input type="checkbox" name="logo_delete" id="logo_delete" value="delete" class="line"/>
          <label for="logo_delete">${_('Delete current logo')}</label>
        </div>
      </td>
      <td class="js-alternatives">
        <h3>${_('Personal information')}</h3>
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

<br />
<form method="post" action="${url(controller='profile', action='update_contacts')}"
      id="contacts_form">
  <table>
    <tr>
      <td style="width: 220px;">&nbsp;</td>
      <td>
        <h3>${_('Contact data')}</h3>
      </td>
    </tr>
    <tr>
      <td style="width: 220px;">&nbsp;</td>
      <td>
        %if c.gg_enabled:
          ${h.input_line('gadugadu_uin', _('Your GG number'))}
          %if c.user.gadugadu_uin:
              %if not c.user.gadugadu_confirmed:
                <span class="unconfirmed">${_('(unconfirmed)')}</span>
                ${h.input_submit(_('Send code again'))}
                ${_("If you want to confirm your GaduGadu number,"
                    " please enter the code that you have received"
                    " in your GG. Also don't forget to add Ututi "
                    "(123345) to your friends.")}
                <br />
                <input type="text" name="gadugadu_confirmation_key" />
                <span class="btn"><input name="confirm_gadugadu" value="${_('OK')}" type="submit"></span>
              %else:
                <input type="hidden"  name="gadugadu_confirmation_key" />
                <span class="confirmed">${_('number is confirmed')}</span>
              %endif
          %else:
          <input type="hidden"  name="gadugadu_confirmation_key" />
          %endif
        %else:
          <input type="hidden"  name="gadugadu_uin" />
          <input type="hidden"  name="gadugadu_confirmation_key" />
        %endif
        ${h.input_line('email', _('Your email address'))}
        %if not c.user.isConfirmed:
          (unconfirmed)
        <div>
          ${h.input_submit(_('Get confirmation email'), name='confirm_email')}
        </div>
        %else:
          <span class="confirmed">${_('email is confirmed')}</span>
        %endif
      </td>
    </tr>
    <tr>
      <td style="width: 220px;">&nbsp;</td>
      <td>
        ${h.input_submit(_('Update contacts'))}
      </td>
    </tr>
  </table>
</form>

<br />
<table>
  <tr>
    <td style="width: 220px;">&nbsp;</td>
    <td>
      <h3>${_('Change your password')}</h3>
    </td>
  </tr>
  <tr>
    <td style="width: 220px;">&nbsp;</td>
    <td>
      <form method="post" action="${url(controller='profile', action='password')}" id="change_password_form">
        ${h.input_psw('password', _('Current password'))}
        ${h.input_psw('new_password', _('New password'))}
        ${h.input_psw('repeat_password', _('Repeat the new password'))}

        ${h.input_submit(_('Change password'))}
      </form>
    </td>
  </tr>
</table>
