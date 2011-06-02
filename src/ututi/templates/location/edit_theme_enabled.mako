<%inherit file="/location/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  .explanation-post-header .tip {
    width: 50%;
  }
  #logo-form {
    float: left;
  }
  #theme-form {
    padding-left: 130px;
  }
  #logo-preview {
    display: block;
    margin-top: 5px;
  }
  #choose-logo-link {
    display: block;
    font-size: 11px;
    margin-top: 10px;
  }
  #disable-theme-button {
    margin-top: 50px;
  }
</%def>

<div class="explanation-post-header" style="margin-top:0">
  <h2>${_('Custom theme')}</h2>
  <p class="tip">
    ${_("Ututi let's you theme your network, "
        "including custom colors, header logo and text.")}
  </p>
</div>

<div id="logo-form">
  <img src="${c.location.theme.url(action='header_logo', size=100)}" id="logo-preview" />
  <a href="#" id="choose-logo-link">${_("Choose other logo")}</a>
</div>

<script type="text/javascript">
  $(document).ready(function() {
    new AjaxUpload('#choose-logo-link', {
        action: "${c.location.theme.url(action='update_header_logo', js=1)}",
        name: 'logo',
        autoSubmit: true,
        responseType: false,
        onSubmit: function(file, extension) {
            if (!(extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))) {
                $('.error-message').remove(); // remove old messages
                $('#logo-preview').after('<span class="error-message">This file type is not supported.</span>');
                return false;
            }
        },
        onComplete: function(file, response) {
            var image_src = "${c.location.theme.url(action='header_logo', size=100)}";
            var timestamp = new Date().getTime();
            $('img#logo-preview').attr('src', image_src + '?' + timestamp);
            $('.error-message').remove();
        }
    });
  });
</script>

<form action="${c.location.url(action='update_theme')}" method="post" id="theme-form">
  ${h.input_line('header_text', _("Header text:"))}
  ${h.input_line('header_background_color', _("Header background color:"))}
  ${h.input_line('header_color', _("Header text color:"))}
  ${h.input_submit()}
</form>

${h.button_to(_("Disable custom theming"),
              c.location.url(action='disable_theme'),
              name='disable_theme',
              class_='dark',
              id='disable-theme-button')}

<script type="text/javascript">
  $(function() {
    $('#disable-theme-button').click(function() {
      // prevent accidental click
      return confirm('${_("Are you sure you want to reset your custom theme?")}');
    });
  });
</script>

