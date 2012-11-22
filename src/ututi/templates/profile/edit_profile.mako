<%inherit file="/profile/edit_base.mako" />
<%namespace name="locationtag" file="/widgets/ulocationtag.mako" import="head_tags"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${locationtag.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
</%def>

<%def name="css()">
  ${parent.css()}
  form.narrow {
    width: 320px;
  }
  .left-right {
    margin-top: 20px;
  }
  #photo-preview {
    margin-bottom: 10px;
  }
  #photo-preview img {
    width: 200px;
    height: 200px;
    padding: 5px;
    border: 1px solid #666666;
  }
  #remove-button {
    margin-top: 20px;
  }

  .base-url {
    color: #666666;
    font-size: 12px;
  }

  #url_name {
    width: 130px;
  }
</%def>

  <div class="left-right">
    <div class="left">
      <form method="post" action="${url(controller='profile', action='update')}"
            name="edit_profile_form" enctype="multipart/form-data" class="narrow">

      <div class="explanation-post-header" style="margin-top:0">
        <h2>${_('General information')}</h2>
        <p class="tip">
          ${_("Edit your general information below.")}
        </p>
      </div>
      ${h.input_line('fullname', _('Full name'))}
      %if c.user.is_teacher:
        ${h.input_line('teacher_position', _('Position'), help_text=_("e.g. Associate professor"))}
        ${h.select_line('teacher_sub_department', _('Sub-department'), [('', 'None')] + [(sd.id, sd.title) for sd in c.sub_departments])}
      %else:
        ${h.input_area('description', _('About yourself'), rows='5', col='40')}
      %endif

      <% help_text = _("Your new url will be: ") + \
             h.literal('<br /><span class="link-color">') + \
             c.user.url(id='', qualified=True) + \
             h.literal('<span id="user-url-preview"></span></span>') %>
      %if c.user.is_teacher:
      <div class="formField">
        <label for="url_name">
          <span class="labelText">${_('Page address')}</span>
          <span class="textField">
          %if c.teachers_url:
          <span class="base-url">${c.teachers_url}</span>
          %else:
            <span class="base-url">${c.user.url(id='', qualified=True)}</span>
            <input id="url_name" type="text" value="" name="url_name" />
          %endif
          </span>
        </label>
      </div>
      %else:
      ${h.input_line('url_name', _('Ututi username'), help_text=help_text)}
      %endif
      <script type="text/javascript">
        function update_url_preview() {
          $('#user-url-preview').html($(this).val());
        }
        $(document).ready(function() {
          $('#url_name').keyup(update_url_preview);
          $('#url_name').change(update_url_preview);
          $('#url_name').change();
        });
      </script>

      %if not c.user.is_teacher:
      <div style="margin-bottom:20px">
        <label for="profile-is-public">
          <input type="checkbox" name="profile_is_public" class="checkbox"
                 id="profile-is-public" />
          ${_('Show my profile to unregistered users and search engines')}
        </label>
      </div>
      %endif

      ${h.input_submit()}
</form>

    </div>
    <div class="right">
      <div class="explanation-post-header" style="margin-top:0">
        <h2>${_("Your profile photo")}</h2>
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


    </div>
  </div>
