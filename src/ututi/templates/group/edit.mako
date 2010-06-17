<%inherit file="/group/base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/group/create_base.mako" import="*"/>

<%def name="group_menu()">
  <h1 class="pageTitle">${self.title()}</h1>
  ${h.link_to(_('Back to group page'), c.group.url())}
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


<form method="post" action="${url(controller='group', action='update', id=c.group.group_id)}" name="edit_profile_form" enctype="multipart/form-data"
      id="group_settings_form">
  <table>
    <tr>
      <td style="width: 180px; padding-top: 30px; vertical-align: top;">
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

        ${logo_field()}
        ${year_field()}

        ${location_field(live_search=False)}

        <br class="clear-left"/>

        ${forum_type()}

        <label for="default_tab">
            <span class="labelText">${_('Default group tab')}</span>
        </label>
        ${h.select("default_tab", c.group.default_tab, c.tabs)}

        <label for="tags"><span class="labelText">${_('Tags')}</span></label>
        ${tags_widget([])}

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

        ${access_settings()}

        <br />

        ${h.input_submit()}
      </td>
  </tr></table>
</form>
