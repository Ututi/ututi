<%inherit file="/location/edit_base.mako" />

<%def name="head_tags()">
  ${h.javascript_link('/lib/colorpicker/js/colorpicker.js')}
  ${h.stylesheet_link('/lib/colorpicker/css/colorpicker.css')}
</%def>

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

<%def name="theme_preview(theme=None)">
<style type="text/css">
  /* Themed header preview */
  #header-preview {
    height: 40px;
    width: 600px;
    overflow: hidden;
    background: #333;
    margin: 20px 0 40px 0;
    box-shadow: 5px 5px 5px #000;
    -moz-box-shadow: 5px 5px 5px #000;
    -webkit-box-shadow: 5px 5px 5px #000;
    %if theme is not None:
    background-color: #${theme.header_background_color};
    %endif
  }

  #header-preview .header-inner {
    padding-top: 10px;
    padding-left: 35px;
  }

  #header-preview .branded-logo {
    float: left;
    width: 135px;
    height: 30px;
    padding-left: 40px;
    text-align: left;
    font-size: 22px;
    font-weight: bold;
    background: url("/img/Ututi_logo_small.png") no-repeat 5px center;
    color: white;
    %if theme is not None:
    background-image: url('${theme.url(action="header_logo", size=25)}');
    color: #${theme.header_color};
    %endif
  }

  #header-preview .top-panel {
    background-color: rgba(255, 255, 255, 0.28);
    float: left;
    width: 390px;
    height: 20px;
    padding: 5px 0;
  }
</style>

<div id="header-preview">
  <div class="header-inner" class="clearfix">
    <div class="branded-logo">
      %if theme is not None:
        ${theme.header_text}
      %else:
        UTUTI
      %endif
    </div>
    <div class="top-panel">
      <ul id="head-nav">
        <li id="nav-home"><a>${_('Home')}</a></li>
        <li id="nav-university"><a>${_('My University')}</a></li>
        <li id="nav-catalog"><a>${_('Catalog')}</a></li>
      </ul>
    </div>
  </div>
</div>
</%def>


<div class="explanation-post-header" style="margin-top:0">
  <h2>${_('Custom theme')}</h2>
  <p class="tip">
    ${_("Ututi let's you theme your network, "
        "including custom colors, header logo and text.")}
  </p>
</div>

${theme_preview(c.theme)}

<div id="logo-form">
  <img src="${c.location.theme.url(action='header_logo', size=100)}" id="logo-preview" />
  <a href="#" id="choose-logo-link">${_("Choose other logo")}</a>
</div>

<form action="${c.location.url(action='update_theme')}" method="post" id="theme-form">
  ${h.input_line('header_text', _("Header text:"), id='header-text-field')}
  ${h.input_line('header_background_color', _("Header background color:"), id='header-background-color-field')}
  ${h.input_line('header_color', _("Header text color:"), id='header-color-field')}
  ${h.input_submit()}
</form>

${h.button_to(_("Disable custom theming"),
              c.location.url(action='disable_theme'),
              name='disable_theme',
              class_='dark',
              id='disable-theme-button')}

<script type="text/javascript">
  $(function() {
    // ajax image upload
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
            var timestamp = new Date().getTime();
            var image_src = "${c.location.theme.url(action='header_logo', size=100)}" + '?' + timestamp;
            var preview_src = "${c.location.theme.url(action='header_logo', size=25)}" + '?' + timestamp;
            $('img#logo-preview').attr('src', image_src);
            $('#header-preview .branded-logo').css('backgroundImage', 'url("' + preview_src + '")');
            $('.error-message').remove();
        }
    });

    // color pickers
    $('#header-background-color-field').ColorPicker({
      onChange: function(hsb, hex, rbg) {
        // does not work with "this"
        $('#header-background-color-field').val(hex);
        $('#header-preview').css('backgroundColor', '#' + hex);
      },
      onBeforeShow: function() {
        $(this).ColorPickerSetColor(this.value);
      }
    });
    $('#header-color-field').ColorPicker({
      onChange: function(hsb, hex, rbg) {
        // does not work with "this"
        $('#header-color-field').val(hex);
        $('#header-preview .branded-logo').css('color', '#' + hex);
      },
      onBeforeShow: function() {
        $(this).ColorPickerSetColor(this.value);
      }
    });

    // header text preview
    function update_header_text() {
      $('#header-preview .branded-logo').html($('#header-text-field').val());
    }
    $('#header-text-field').keyup(update_header_text);
    $('#header-text-field').change(update_header_text);

    // prevent disable accidental click
    $('#disable-theme-button').click(function() {
      return confirm('${_("Are you sure you want to reset your custom theme?")}');
    });
  });
</script>

