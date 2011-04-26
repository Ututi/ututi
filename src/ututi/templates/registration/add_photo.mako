<%inherit file="/registration/base.mako" />

<%def name="css()">
  ${parent.css()}
  #photo-preview {
    float: left;
    margin-right: 40px;
    margin-bottom: 10px;
  }
  #photo-preview img {
    padding: 5px;
    border: 1px solid #666666;
  }
  #skip-link {
    float: right;
    margin-top: -10px;
  }
  #add-photo-form {
    padding-top: 5px;
  }
  p#help-text {
    color: #666666;
  }
  #choose-button {
    margin-right: 20px;
  }
</%def>

<%def name="pagetitle()">${_("Add your photo")}</%def>

<div id="photo-preview">
  <img src="${url(controller='registration', action='logo', id=c.registration.id, size=140)}" />
</div>

<form id="add-photo-form"
      action="${c.registration.url(action='add_photo')}"
      enctype="multipart/form-data"
      method="POST">

  <p>
    ${_("Select an image file on your computer:")}
  </p>

  <input type="file" name="photo" id="photo-field" />
  <form:error name="photo-field" /> <!-- formencode errors container -->

  <button id="choose-button" class="dark" style="display: none">${_("Choose")}</button>

  <% replace_photo_text = _("Select an image if you want to replace your photo") %>

  %if c.registration.has_logo():
  <p id="help-text">
    ${replace_photo_text}
  </p>
  %else:
  <p id="help-text">
    ${_("You have not set your photo yet")}
  </p>
  %endif

  <div>
    ${h.input_submit(_("Next"))}
    <a id="skip-link" href="${c.registration.url(action='invite_friends')}">
      ${_("Skip")}
    </a>
  </div>
</form>

<script type="text/javascript">
  $(document).ready(function() {

    $('#photo-field').hide();
    $('#choose-button').show();

    new AjaxUpload('#choose-button', {
        action: "${c.registration.url(action='add_photo')}" + "?js",
        name: 'photo',
        autoSubmit: true,
        responseType: false,
        onSubmit: function(file, extension) {
            if (!(extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))) {
                $('.error-message').remove(); // remove old messages
                $('#choose-button').after('<span class="error-message">This file type is not supported.</span>');
                return false;
            }
        },
        onComplete: function(file, response) {
            var image_src = "${url(controller='registration', action='logo', id=c.registration.id, size=140)}";
            var timestamp = new Date().getTime();
            $('#photo-preview img').attr('src', image_src + '?' + timestamp);
            $('#help-text').html('${replace_photo_text}');
            $('.error-message').remove();
        }
    });

  });
</script>
