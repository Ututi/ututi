<%inherit file="/profile/settings/base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
  ${h.javascript_link('/javascript/js-alternatives.js')|n}
  <%newlocationtag:head_tags />
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

<%def name="pagetitle()">${_("General information")}</%def>

<%def name="form()">
  <div id="general-information-settings">
    <form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" enctype="multipart/form-data" class="new-style-form"> 
      <div class="js-alternatives" id="user-logo">
        <img src="${url(controller='profile', action='logo', width='120', height='200')}" alt="User logo" id="user-logo-editable"/>
        <div>
          <div id="user-logo-button" >${_('Change picture')}</div>
        </div>
        <br style="clear: left;" />
        <div class="no-break">
          <label for="logo_delete">
            <input type="checkbox" class="checkbox" name="logo_delete" id="logo_delete" value="delete" />
            ${_('Delete current picture')}
          </label>
        </div>
      </div>

      <div class="js-alternatives" id="general-information-form">

        <fieldset>
        ${h.input_line('fullname', _('Full name'))}
        <div>
          ${location_widget(2, add_new=(c.tpl_lang=='pl'))}
        </div>

        ${h.input_line('site_url', _('Address of your website or blog'))}
        %if not c.user.is_teacher:
        ${h.input_area('description', _('About yourself'), rows='5', col='40')}
        %endif

        <div style="padding-top: 5px">
          <label for="profile_is_public">
            <input type="checkbox" name="profile_is_public" class="checkbox"
                   id="profile_is_public" />

            ${_('Show my profile to unregistered users and search engines')}
          </label>
        </div>

        <div class="non-js">
          <label for="logo_upload">${_('Picture')}</label>
          <input type="file" name="logo_upload" id="logo_upload" class="line" />
        </div>
        ${h.input_submit(class_="btnMedium")}
        </fieldset>
      </div>
    </form>

    <form method="post" action="${url(controller='profile', action='password')}" id="change-password-form" class="new-style-form">
      <h1 class='page-title'>${_('Change password')}:</h1>
      <fieldset>
      ${h.input_psw('password', _('Current password'))}
      ${h.input_psw('new_password', _('New password'))}
      ${h.input_psw('repeat_password', _('Repeat the new password'))}
      ${h.input_submit(_('Change password'), class_='btnMedium')}
      </fieldset>
    </form>
  </div>
</%def>

${self.form()}
