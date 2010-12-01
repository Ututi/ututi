<%inherit file="/profile/edit.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="pagetitle()">
${_('Profile settings')}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
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

<form method="post" action="${url(controller='profile', action='update')}" name="edit_profile_form" id="edit_profile_form" enctype="multipart/form-data" class="fullForm">
  <div class="js-alternatives" id="user-logo">
    <img src="${url(controller='profile', action='logo', width='120', height='200')}" alt="User logo" id="user-logo-editable"/>
    <div>
      <div id="user-logo-button" >${_('Change logo')}</div>
    </div>
    <br style="clear: left;" />
    <div class="no-break">
      <label for="logo_delete">
        <input type="checkbox" class="checkbox" name="logo_delete" id="logo_delete" value="delete" />
        ${_('Delete current logo')}
      </label>
    </div>
  </div>

  <div class="js-alternatives">
    <fieldset>
    ${h.input_line('fullname', _('Full name'))}
    <div>
      ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=False)}
    </div>

    ${h.input_line('site_url', _('Address of your website or blog'))}
    ${h.input_area('description', _('About yourself'), rows='6', cols='50')}

    <div style="padding-top: 5px">
      <label for="profile_is_public">
        <input type="checkbox" name="profile_is_public" class="checkbox"
               id="profile_is_public" />

        ${_('Show my profile to unregistered users and search engines')}
      </label>
    </div>

    <div class="non-js">
      <label for="logo_upload">${_('Personal logo')}</label>
      <input type="file" name="logo_upload" id="logo_upload" class="line" />
    </div>
    ${h.input_submit(class_="btnMedium")}
    </fieldset>
  </div>

</form>
