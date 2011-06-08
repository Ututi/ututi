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
</%def>

<form method="post" action="${url(controller='profile', action='update')}"
      name="edit_profile_form" enctype="multipart/form-data" class="narrow">
  <div class="left-right">
    <div class="left">
      <div class="explanation-post-header" style="margin-top:0">
        <h2>${_('General information')}</h2>
        <p class="tip">
          ${_("Edit your general information below.")}
        </p>
      </div>
      ${h.input_line('fullname', _('Full name'))}
      ${locationtag.location_widget(2, add_new=(c.tpl_lang=='pl'))}
      %if c.user.is_teacher:
        ${h.input_line('teacher_position', _('Position'), help_text=_("e.g. Associate professor"))}
      %else:
        ${h.input_area('description', _('About yourself'), rows='5', col='40')}
      %endif
      ${h.input_submit()}
    </div>
    <div class="right">
      <div class="explanation-post-header" style="margin-top:0">
        <h2>${_("Profile page")}</h2>
        <p class="tip">
          <% user_url = c.user.url(qualified=True) %>
          ${_("You can set a Ututi username to have a more personal URL of your profile page.")}
          ${h.literal(_("Your current public profile page is %(user_url)s.") % dict(user_url=h.link_to(user_url, user_url)))}
        </p>
      </div>
      <% help_text = _("Your new url will be: ") + \
             h.literal('<br /><span class="link-color">') + \
             c.user.url(id='', qualified=True) + \
             h.literal('<span id="user-url-preview"></span></span>') %>
      ${h.input_line('url_name', _('Ututi username'), help_text=help_text)}
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
      <div style="margin-bottom:20px">
        <label for="profile-is-public">
          <input type="checkbox" name="profile_is_public" class="checkbox"
                 id="profile-is-public" />
          ${_('Show my profile to unregistered users and search engines')}
        </label>
      </div>

      ${h.input_submit()}
    </div>
  </div>
</form>
