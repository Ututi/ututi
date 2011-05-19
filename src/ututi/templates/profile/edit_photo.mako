<%inherit file="/profile/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  #photo-preview {
    margin-bottom: 10px;
  }
  #photo-preview img {
    width: 300px;
    height: 300px;
    padding: 5px;
    border: 1px solid #666666;
  }
  #remove-button {
    margin-top: 20px;
  }
</%def>

<div class="explanation-post-header">
  <h2>${_('Your profile photo')}</h2>
  <p class="tip">
    ${_("Change or remove your profile photo.")}
  </p>
</div>

<div id="photo-preview">
  <img src="${c.user.url(action='logo', width=300)}" />
</div>

<form id="photo-form"
      action="${url(controller='profile', action='update_photo')}"
      enctype="multipart/form-data"
      method="POST">

  <input type="file" name="logo" id="logo-field" />
  <form:error name="logo" /> <!-- formencode errors container -->

  ${h.input_submit(_("Change photo"), name='change', id='choose-button')}
</form>

${h.button_to(_("Remove"), url(controller='profile', action='remove_photo'),
              id='remove-button', class_='dark')}

<script type="text/javascript">
  $(document).ready(function() {
    $('#logo-field').hide();
    new AjaxUpload('#choose-button', {
        action: "${url(controller='profile', action='update_photo')}" + "?js",
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
            var image_src = "${c.user.url(action='logo', width=300)}";
            var timestamp = new Date().getTime();
            $('#photo-preview img').attr('src', image_src + '?' + timestamp);
            $('.error-message').remove();
        }
    });
  });
</script>
