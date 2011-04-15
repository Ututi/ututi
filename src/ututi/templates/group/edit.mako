<%inherit file="/group/base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/group/create_base.mako" import="*"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="group_menu()">

  <div class="with-bottom-line clearfix">
    <h1 class="page-title " style="float: left;">${self.title()}</h1>
    <div class="back-link" style="float: right;">
      <a class="back-link" href="${c.group.url()}">${_('Back')}</a>
    </div>
  </div>

</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${parent.head_tags()}

${h.javascript_link('/javascript/js-alternatives.js')|n}
  <script type="text/javascript">
  //<![CDATA[
  $(document).ready(function() {
    new AjaxUpload('#group-logo-editable', {
      action: '${url(controller="group", id=c.group.group_id, action="logo_upload")}',
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
        var img_id = '#group-logo-editable';
        var img_src = "${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}";
        var timestamp = new Date().getTime();
        $(img_id).attr('src', img_src+'?'+timestamp);
      }
    });
    new AjaxUpload('#group-logo-button', {
      action: '${url(controller="group", id=c.group.group_id, action="logo_upload")}',
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
        var img_id = '#group-logo-editable';
        var img_src = "${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}";
        var timestamp = new Date().getTime();
        $(img_id).attr('src', img_src+'?'+timestamp);
      }
    });

   });
  //]]>
  </script>
</%def>

<%def name="css()">
  ${parent.css()}

  .with-bottom-line {
     border-bottom: 1px solid #FF9900;
     margin-bottom: 10px;
  }

  h1.page-title {
     margin-bottom: 0;
  }

  h2.subtitle {
     font-size: 14px;
     font-weight: bold;
     margin-top: 15px;
     margin-bottom: 10px;
     padding-bottom: 2px;
     border-bottom: 1px solid #FF9900;
  }

  .privacy-settings {
     margin-left: 180px;
  }

     .privacy-settings .labelText {
        font-size: 13px;
        margin-top: 15px;
     }

     .privacy-settings input {
        margin-top: 5px;
     }

</%def>


<form method="post" action="${url(controller='group', action='update', id=c.group.group_id)}" name="edit_profile_form" enctype="multipart/form-data"
      id="group_settings_form">
  <table>
    <tr>
      <td style="width: 180px; padding-top: 10px; vertical-align: top;">
        <div class="js-alternatives" id="group-logo">
          <img src="${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}" alt="Group logo" id="group-logo-editable"/>
          <button id="group-logo-button" class="btn">
              <span>${_('Change logo')}</span>
          </button>
        </div>
        <br class="clear-left"/>
        <label>
          <input type="checkbox" name="logo_delete" id="logo_delete" value="true"/>
          ${_('Delete current logo')}
        </label>
      </td>
      <td class="js-alternatives">

        ${group_title_field()}
        ${description_field()}

        %if h.check_crowds(['root']):
        <div class="form-field">
          <label for="moderators">
            % if c.group.moderators:
            <input name="moderators" id="moderators" type="checkbox" value="true" checked="checked" />
            % else:
            <input name="moderators" id="moderators" type="checkbox" value="true" />
            % endif
            ${_("Moderators")}
          </label>
        </div>
        %endif

        ${year_field()}

        <div style="display:none;">
          ${logo_field()}
          ${location_field()}
        </div>

        <label for="default_tab">
          <span class="labelText">${_('Default group tab')}</span>
        </label>
        ${h.select("default_tab", c.group.default_tab, c.tabs)}

      </td>
  </tr></table>

  <h2 class="subtitle">${_('Access settings:')}</h2>
  <div class="privacy-settings">

    <label for="approve_new_members" class="radio">
      <span class="labelText">${_('Joining the group:')}</span>
      ${h.radio("approve_new_members", "none",
      label=_('Anyone can join the group;'))}
      <br />
      ${h.radio("approve_new_members", "admin",
      label=_('Administrators have to approve new members.'))}
    </label>

    <label for="forum_visibility" class="radio">
      <span class="labelText">${_('Group discussions are visibile for:')}</span>
      ${h.radio("forum_visibility", "public", label=_('Everybody;'))}
      <br />
      ${h.radio("forum_visibility", "members", label=_('Group members only.'))}
    </label>

    <label for="mailing_list_moderation" class="radio">
      <span class="labelText">
        ${_('Who can send messages to the mailing list:')}
      </span>
      ${h.radio("mailinglist_moderated", "members", label=_('Members only;'))}
      <br />
      ${h.radio("mailinglist_moderated", "moderated", label=_('Everybody (moderated).'))}
      ${tooltip(_("If you select 'moderated', you can pick the people "
      "who you want to allow to post to the mailing list."))}
    </label>

    ${h.input_submit()}
</div>

</form>

<h2 class="subtitle">${_('Delete group:')}</h2>
<div class="delete-group">
</div>
