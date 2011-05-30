<%inherit file="/location/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  .left-right {
    margin-top: 20px;
  }
  #logo-preview {
    margin-bottom: 10px;
  }
  #logo-preview img {
    width: 200px;
    padding: 5px;
    border: 1px solid #666666;
  }
  #remove-button {
    margin-top: 20px;
  }
</%def>

<div class="left-right">

  <div class="left">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('General information')}</h2>
      <p class="tip">
        ${_("Edit general information of your university below.")}
      </p>
    </div>
    <form method="post" action="${c.location.url(action='update')}"
          name="edit_structure_form" class="edit-form">

      <input type="hidden" name="old_path" value="" />
      ${h.input_line('title', _("Full University title:"))}
      ${h.input_line('title_short', _('Short title:'))}
      ${h.country_select(_("Country:"), empty_name=_("(Select country from list)"))}
      ${h.input_line('site_url', _("University website:"))}
      ${h.input_area('description', _("Description:"))}
      ${h.input_submit()}
    </form>
  </div>

  <div class="right">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('University logo')}</h2>
      <p class="tip">
        ${_("Upload a high quality logo for your University.")}
      </p>
    </div>

    <div id="logo-preview">
      <img src="${url(controller='structure', action='logo', id=c.location.id, width=200)}" />
    </div>

    <form id="logo-form"
          action="${c.location.url(action='update_logo')}"
          enctype="multipart/form-data"
          method="POST">

      <input type="file" name="logo" id="logo-field" />
      <form:error name="logo" /> <!-- formencode errors container -->

      ${h.input_submit(_("Change logo"), name='change', id='choose-button')}
    </form>

    ${h.button_to(_("Remove"), c.location.url(action='remove_logo'),
                  id='remove-button', class_='dark')}

    <script type="text/javascript">
      $(document).ready(function() {
        $('#logo-field').hide();
        new AjaxUpload('#choose-button', {
            action: "${c.location.url(action='update_logo')}" + "?js",
            name: 'logo',
            autoSubmit: true,
            responseType: false,
            onSubmit: function(file, extension) {
                if (!(extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))) {
                    $('.error-message').remove(); // remove old messages
                    $('#logo-field').before('<span class="error-message">This file type is not supported.</span>');
                    return false;
                }
            },
            onComplete: function(file, response) {
                var image_src = "${url(controller='structure', action='logo', id=c.location.id, width=200)}";
                var timestamp = new Date().getTime();
                $('#logo-preview img').attr('src', image_src + '?' + timestamp);
                $('.error-message').remove();
            }
        });
      });
    </script>
  </div>
</div>
